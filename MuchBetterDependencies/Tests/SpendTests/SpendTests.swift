import Common
import ComposableArchitecture
import SnapshotTesting
@testable import SpendFeature
import SwiftUI
import XCTest

class SpendTests: XCTestCase {
    func testSpend() {
        let store = TestStore(initialState: SpendState(),
                              reducer: spendReducer,
                              environment: SpendEnvironment.mock)

        store.assert(
            .send(SpendAction.descriptionChanged("Test description")) {
                $0.description = "Test description"
            },
            .send(SpendAction.amountChanged("111.11")) {
                $0.amount = "111.11"
            },
            .send(.spendRequest),
            .receive(.spendResponse(.success(""))) {
                $0.description = "Test description"
            }
        )
    }

    func testSpendFail() {
        let failMock = SpendEnvironment.failing

        let store = TestStore(initialState: SpendState(),
                              reducer: spendReducer,
                              environment: failMock)

        let expected = SpendError.message("Error") as NSError

        store.assert(
            .send(.spendRequest),
            .receive(.spendResponse(.failure(expected))) {
                $0.description = ""
                $0.amount = ""
            }
        )
    }

    func testSpendErrorLocalization() {
        let error = SpendError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
