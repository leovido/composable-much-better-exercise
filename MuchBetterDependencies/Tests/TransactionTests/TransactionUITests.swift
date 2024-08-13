import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
@testable import TransactionFeature

@MainActor
final class TransactionUITests: XCTestCase {
  func testTransactionList_Empty() {
    let store: StoreOf<TransactionReducer> = .init(
			initialState: TransactionReducer.State(),
			reducer: { TransactionReducer() },
			withDependencies: {
				$0.transactionClient = .init(fetchTransactions: {
					return []
				})
			}
    )

    let transactionView = UIHostingController(rootView: TransactionView(store: store))

		assertSnapshot(of: transactionView, as: .image(on: .iPhoneXsMax))
  }

  func testTransactionList_NonEmpty() async {
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
		
    let store: StoreOf<TransactionReducer> = .init(
			initialState: TransactionReducer.State(transactions: mockTransactions, viewState: .nonEmpty),
			reducer: { TransactionReducer() },
			withDependencies: {
				$0.mainQueue = .immediate
				$0.transactionClient = .testValue
			}
    )

		let transactionView = UIHostingController(rootView: TransactionView(store: store))

    assertSnapshot(of: transactionView, as: .image(on: .iPhoneXsMax))
  }
}
