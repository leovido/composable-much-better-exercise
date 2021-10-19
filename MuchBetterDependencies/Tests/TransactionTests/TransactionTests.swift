import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import TransactionFeature
import XCTest

class TransactionTests: XCTestCase {
    func testFetchTransactions() {
        let state = TransactionState()

        let store = TestStore(initialState: state,
                              reducer: transactionReducer,
                              environment: TransactionEnvironment.mock)

        let mockTransactions = [
            Transaction(id: UUID().uuidString, date: Date(), description: "Test description", amount: "111.11", currency: .gbp),
            Transaction(id: UUID().uuidString, date: Date(), description: "Much better transaction", amount: "777.77", currency: .gbp),
        ]

        store.environment.fetchTransactions = {
            Effect(value: mockTransactions)
        }

        store.assert(
            .send(TransactionAction.fetchTransactions),
            .receive(.receiveTransactions(.success(mockTransactions))) {
                $0.transactions = mockTransactions
                $0.filteredTransactions = mockTransactions
            }
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

        let expected = initialMockTransactions.last!

        /// Here we have full control on what mock transactions we want to return. Realistically, the Date properties created above will be different to the ones created on the actual mock implementation of the `TransactionEnvironment.mock`. This will allow us to have full control on the exact Date that we pass.
        /// You can test it yoursel by removing the lines 46-48 and run the test. It will fail with a diff on the date property.
        store.environment.fetchTransactions = {
            Effect(value: initialMockTransactions)
        }

        store.assert(
            .send(TransactionAction.fetchTransactions),
            .receive(.receiveTransactions(.success(initialMockTransactions))) {
                $0.transactions = initialMockTransactions
                $0.filteredTransactions = initialMockTransactions
            },
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

        let expected = TransactionError.message("Error")

        store.assert(
            .send(.fetchTransactions),
            .receive(.receiveTransactions(.failure(expected)))
        )
    }

    func testUI() {
        let store: Store<TransactionState, TransactionAction> = .init(
            initialState: .init(transactions: [], searchText: ""),
            reducer: transactionReducer,
            environment: TransactionEnvironment.mock
        )

        let transactionView = UIHostingController(rootView: TransactionView(store: store))

        assertSnapshot(matching: transactionView, as: .image(on: .iPhoneXsMax))
    }

    func testTransactionErrorLocalization() {
        let error = TransactionError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
