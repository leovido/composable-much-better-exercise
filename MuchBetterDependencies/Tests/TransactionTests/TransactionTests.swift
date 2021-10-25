import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import TransactionFeature
import XCTest

class TransactionTests: XCTestCase {
    func testFetchTransactions() {
        let store = TestStore(initialState: TransactionState(),
                              reducer: transactionReducer,
                              environment: TransactionEnvironment.mock)

        let expectedSort = TransactionSort.oldToNew

        let mockTransactions = [
            Transaction(id: UUID().uuidString, date: Date(), description: "Test description", amount: "111.11", currency: .gbp),
            Transaction(id: UUID().uuidString, date: Date(), description: "Much better transaction", amount: "777.77", currency: .gbp),
        ]

        store.environment.fetchTransactions = {
            Effect(value: mockTransactions)
        }

        store.assert(
            .send(TransactionAction.fetchTransactions) {
                $0.viewState = .loading
            },
            .receive(.receiveTransactions(.success(mockTransactions))) {
                $0.transactions = mockTransactions
                $0.filteredTransactions = mockTransactions
                $0.viewState = .nonEmpty
            },
            .receive(.sortTransactions(expectedSort))
        )
    }

    func testFilterTransactionsAndSearchFeature() {
        let store = TestStore(initialState: TransactionState(),
                              reducer: transactionReducer,
                              environment: TransactionEnvironment.mock)

        let initialMockTransactions = [
            Transaction(id: UUID().uuidString, date: Date(), description: "Test description", amount: "111.11", currency: .gbp),
            Transaction(id: UUID().uuidString, date: Date(), description: "Much better transaction", amount: "777.77", currency: .gbp),
        ]

        let expectedSort = TransactionSort.oldToNew
        let expected = initialMockTransactions.last!

        /// Here we have full control on what mock transactions we want to return. Realistically, the Date properties created above will be different to the ones created on the actual mock implementation of the `TransactionEnvironment.mock`. This will allow us to have full control on the exact Date that we pass.
        /// You can test it yoursel by removing the lines 46-48 and run the test. It will fail with a diff on the date property.
        store.environment.fetchTransactions = {
            Effect(value: initialMockTransactions)
        }

        store.assert(
            .send(TransactionAction.fetchTransactions) {
                $0.viewState = .loading
            },
            .receive(.receiveTransactions(.success(initialMockTransactions))) {
                $0.transactions = initialMockTransactions
                $0.filteredTransactions = initialMockTransactions
                $0.viewState = .nonEmpty
            },
            .receive(.sortTransactions(expectedSort)),
            .send(.searchTextChanged("M")) {
                $0.searchText = "M"
                $0.filteredTransactions = [expected]
            },
            .send(.searchTextChanged("Mu")) {
                $0.searchText = "Mu"
                $0.filteredTransactions = [expected]
            },
            .send(.searchTextChanged("Muc")) {
                $0.searchText = "Muc"
                $0.filteredTransactions = [expected]
            },
            .send(.searchTextChanged("Much")) {
                $0.searchText = "Much"
                $0.filteredTransactions = [expected]
            },
            .send(.searchTextChanged("")) {
                $0.searchText = ""
                $0.filteredTransactions = initialMockTransactions
            }
        )
    }

    func testFetchTransactionsError() {
        let failMock = TransactionEnvironment.failing

        let store = TestStore(initialState: TransactionState(),
                              reducer: transactionReducer,
                              environment: failMock)

        let expectedAlert = AlertState(
            title: TextState("Error"),
            message: TextState("Error"),
            dismissButton: .default(TextState("Ok"),
                                    action: .send(TransactionAction.dismissAlert))
        )

        let expected = TransactionError.message("Error")

        store.assert(
            .send(.fetchTransactions) {
                $0.viewState = .loading
            },
            .receive(.receiveTransactions(.failure(expected))) {
                $0.transactionAlert = expectedAlert
                $0.viewState = .empty
            }
        )
    }

    func testTransactionErrorLocalization() {
        let error = TransactionError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
