import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import TransactionFeature

@MainActor
final class TransactionTests: XCTestCase {
	func testFetchTransactions() async {
		let mockTransactions = [
			Transaction(
				id: UUID().uuidString,
				date: Date(),
				description: "Test description",
				amount: "111.11",
				currency: .gbp
			),
			Transaction(
				id: UUID().uuidString,
				date: Date(),
				description: "Much better transaction",
				amount: "777.77",
				currency: .gbp
			),
		]
		
		let store = TestStore(initialState: TransactionReducer.State(),
													reducer: {
			TransactionReducer()
		}) {
			$0.mainQueue = .immediate
			$0.transactionClient = .init(fetchTransactions: {
				return mockTransactions
			})
		}
		
		let expectedSort = TransactionSort.oldToNew
		
		
		await store.send(.fetchTransactions) {
			$0.viewState = .loading
		}
		
		await store.receive(.receiveTransactions(.success(mockTransactions))) {
			$0.transactions = mockTransactions
			$0.filteredTransactions = mockTransactions
			$0.viewState = .nonEmpty
		}
		await store.receive(.sortTransactions(expectedSort))
	}
	
	func testSortedTransactionsHighLow() async {
		let expectedTransactions = [
			Transaction(date: Date(), description: "Cricket bet", amount: "200", currency: .gbp),
			Transaction(date: Date(), description: "Football bet", amount: "500", currency: .gbp),
		]
		
		let store = TestStore(
			initialState: TransactionReducer.State(transactions: expectedTransactions, sort: .highLowPrice),
			reducer: {
				TransactionReducer()
			},
			withDependencies: {
				$0.transactionClient = .testValue
			}
		)
		
		let expectedSort = TransactionSort.highLowPrice
		
		await store.send(.sortTransactions(expectedSort))
	}
	
	func testSortedTransactionsLowHigh() async {
		let expectedTransactions = [
			Transaction(date: Date(), description: "Football bet", amount: "500", currency: .gbp),
			Transaction(date: Date(), description: "Cricket bet", amount: "200", currency: .gbp),
		]
		
		let store = TestStore(
			initialState: TransactionReducer.State(transactions: expectedTransactions, sort: .lowHighPrice),
			reducer: {
				TransactionReducer()
			},
			withDependencies: {
				$0.transactionClient = .init(fetchTransactions: {
					expectedTransactions
				})
			}
		)
		
		let expectedSort = TransactionSort.lowHighPrice
		
		await store.send(.sortTransactions(expectedSort))
	}
	
	func testSortedTransactionsNewOld() async {
		let expectedTransactions = [
			Transaction(date: Date(), description: "Football bet", amount: "500", currency: .gbp),
			Transaction(date: Date().advanced(by: 3600), description: "Cricket bet", amount: "200", currency: .gbp),
		]
		
		let store = TestStore(
			initialState: TransactionReducer.State(transactions: expectedTransactions, sort: .lowHighPrice),
			reducer: {
				TransactionReducer()
			},
			withDependencies: {
				$0.transactionClient = .init(fetchTransactions: {
					expectedTransactions
				})
			}
		)
		
		let expectedSort = TransactionSort.newToOld
		
		await store.send(.sortTransactions(expectedSort)) {
			$0.sort = expectedSort
			$0.filteredTransactions = expectedTransactions
				.sorted(by: { $0.date > $1.date })
		}
	}
	
	func testSortedTransactionsOldNew() async {
		let expectedTransactions = [
			Transaction(date: Date(), description: "Football bet", amount: "500", currency: .gbp),
			Transaction(date: Date().advanced(by: 3600), description: "Cricket bet", amount: "200", currency: .gbp),
		]
		
		let store = TestStore(
			initialState: TransactionReducer.State(transactions: expectedTransactions, sort: .lowHighPrice),
			reducer: {
				TransactionReducer()
			},
			withDependencies: {
				$0.transactionClient = .init(fetchTransactions: {
					expectedTransactions
				})
			}
		)
		
		let expectedSort = TransactionSort.oldToNew
		
		await store.send(.sortTransactions(expectedSort)) {
			$0.sort = expectedSort
			$0.filteredTransactions = expectedTransactions
				.sorted(by: { $0.date < $1.date })
		}
	}
	
	func testFilterTransactionsAndSearchFeature() async {
		let initialMockTransactions = [
			Transaction(id: UUID().uuidString,
									date: Date(),
									description: "Test description",
									amount: "111.11",
									currency: .gbp),
			Transaction(id: UUID().uuidString,
									date: Date(),
									description: "Much better transaction",
									amount: "777.77",
									currency: .gbp),
		]
		
		let store = TestStore(
			initialState: TransactionReducer.State(transactions: [], sort: .lowHighPrice),
			reducer: {
				TransactionReducer()
			},
			withDependencies: {
				$0.transactionClient = .testValue
			}
		)
		
		let expectedSort = TransactionSort.lowHighPrice
		let expected = initialMockTransactions.last!
		
		store.dependencies.transactionClient.fetchTransactions = {
			return initialMockTransactions
		}
		
		await store.send(.fetchTransactions) {
			$0.viewState = .loading
		}
		
		await store.receive(.receiveTransactions(.success(initialMockTransactions))) {
			$0.transactions = initialMockTransactions
			$0.filteredTransactions = initialMockTransactions
			$0.viewState = .nonEmpty
		}
		await store
			.receive(.sortTransactions(expectedSort))
		
		await store
			.send(.searchTextChanged("M")) {
				$0.searchText = "M"
				$0.filteredTransactions = [expected]
			}
		
		await store
			.send(.searchTextChanged("Mu")) {
				$0.searchText = "Mu"
				$0.filteredTransactions = [expected]
			}
		
		await store
			.send(.searchTextChanged("Muc")) {
				$0.searchText = "Muc"
				$0.filteredTransactions = [expected]
			}
		
		await store
			.send(.searchTextChanged("Much")) {
				$0.searchText = "Much"
				$0.filteredTransactions = [expected]
			}
	}
	
	func testFetchTransactionsError() async {
		let store = TestStore(
			initialState: TransactionReducer.State(transactions: [], sort: .lowHighPrice),
			reducer: {
				TransactionReducer()
			},
			withDependencies: {
				$0.transactionClient = .previewValue
			}
		)
		
		let expectedAlert = AlertState(
			title: TextState("Error"),
			message: TextState("Error"),
			dismissButton: .default(TextState("Ok"),
															action: .send(TransactionReducer.Action.dismissAlert))
		)
		
		let expected = TransactionError.message("Error")
		
		await store
			.send(.fetchTransactions) {
				$0.viewState = .loading
			}
		await store
			.receive(.receiveTransactions(.failure(expected))) {
				$0.transactionAlert = expectedAlert
				$0.viewState = .empty
			}
		await store
			.send(.dismissAlert) {
				$0.transactionAlert = nil
			}
	}
	
	func testTransactionErrorLocalization() {
		let error = TransactionError.message("Error")
		XCTAssertEqual(error.localizedDescription, "Error")
	}
}
