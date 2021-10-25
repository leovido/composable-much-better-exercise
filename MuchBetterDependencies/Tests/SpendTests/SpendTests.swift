import Common
import ComposableArchitecture
import SnapshotTesting
@testable import SpendFeature
import SwiftUI
import XCTest

final class SpendTests: XCTestCase {
    func testSpend() {
        let store = TestStore(initialState: SpendState(),
                              reducer: spendReducer,
                              environment: SpendEnvironment.mock)

        let expectedAlert = AlertState(
            title: TextState("Success"),
            message: TextState("Successfully created a new transactions"),
            dismissButton: .default(TextState("Ok"),
                                    action: .send(SpendAction.dismissAlert))
        )

        store.assert(
            .send(SpendAction.descriptionChanged("Test description")) {
                $0.description = "Test description"
            },
            .send(SpendAction.amountChanged("111.11")) {
                $0.amount = "111.11"
            },
            .send(.spendRequest),
            .receive(.spendResponse(.success(""))) {
                $0.description = ""
                $0.amount = ""
                $0.spendAlert = expectedAlert
            }
        )
    }

    func testFieldsEmptyResponse() {
        let failMock = SpendEnvironment.failing
        let expectedAlert = AlertState(
            title: TextState("Warning"),
            message: TextState("Description and Amount fields are required"),
            dismissButton: .default(TextState("Ok"),
                                    action: .send(SpendAction.dismissAlert))
        )

        let store = TestStore(initialState: SpendState(),
                              reducer: spendReducer,
                              environment: failMock)

        store.assert(
            .send(.spendRequest),
            .receive(.fieldsEmptyResponse) {
                $0.spendAlert = expectedAlert
            },
            .send(.dismissAlert) {
                $0.spendAlert = nil
            }
        )
    }

    func testSpendFail() {
        let failMock = SpendEnvironment.failing
        let expectedAlert = AlertState(
            title: TextState("Error"),
            message: TextState("Error"),
            dismissButton: .default(TextState("Ok"),
                                    action: .send(SpendAction.dismissAlert))
        )

        let store = TestStore(
            initialState: SpendState(
                description: "Legit transaction",
                amount: "100.01"
            ),
            reducer: spendReducer,
            environment: failMock
        )

        let expected = SpendError.message("Error") as NSError

        store.assert(
            .send(.spendRequest),
            .receive(.spendResponse(.failure(expected))) {
                $0.description = "Legit transaction"
                $0.amount = "100.01"
                $0.spendAlert = expectedAlert
            }
        )
    }

    func testSpendErrorLocalization() {
        let error = SpendError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
