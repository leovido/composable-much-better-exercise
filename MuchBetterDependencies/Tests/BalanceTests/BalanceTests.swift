@testable import BalanceFeature
import Common
import ComposableArchitecture
import XCTest

final class BalanceTest: XCTestCase {
    func testFetchBalance() {
        let store = TestStore(initialState: BalanceState(balance: "111.11"),
                              reducer: balanceReducer,
                              environment: BalanceEnvironment.mock)

        let expected = Balance(balance: "111.11", currency: .gbp)

        store.assert(
            .send(.requestFetchBalance),
            .receive(.responseReceiveFetchBalance(.success(expected))) {
                $0.balance = "£111.11"
            }
        )
    }

    func testFetchBalanceFail() {
        let failMock = BalanceEnvironment.failing

        let store = TestStore(initialState: BalanceState(balance: "111.11"),
                              reducer: balanceReducer,
                              environment: failMock)

        let expected = BalanceError.message("Error")

        store.assert(
            .send(.requestFetchBalance),
            .receive(.responseReceiveFetchBalance(.failure(expected))) {
                $0.balance = ""
            }
        )
    }

    func testBalanceErrorLocalization() {
        let error = BalanceError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
