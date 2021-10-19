import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import TransactionFeature
import XCTest

final class TransactionUITests: XCTestCase {
    func testTransactionList() {
        let store: Store<TransactionState, TransactionAction> = .init(
            initialState: .init(transactions: [], searchText: ""),
            reducer: transactionReducer,
            environment: TransactionEnvironment.mock
        )

        let transactionView = UIHostingController(rootView: TransactionView(store: store))

        assertSnapshot(matching: transactionView, as: .image(on: .iPhoneXsMax))
    }
}
