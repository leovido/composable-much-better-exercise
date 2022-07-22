import Common
import ComposableArchitecture
import XCTest
@testable import BalanceFeature

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
    let expectedAlert = AlertState(
      title: TextState("Error"),
      message: TextState("Error"),
      dismissButton: .default(TextState("Ok"),
                              action: .send(BalanceAction.dismissAlert))
    )

    let store = TestStore(initialState: BalanceState(balance: "111.11"),
                          reducer: balanceReducer,
                          environment: failMock)

    let expected = BalanceError.message("Error")

    store.assert(
      .send(.requestFetchBalance),
      .receive(.responseReceiveFetchBalance(.failure(expected))) {
        $0.balance = ""
        $0.balanceAlert = expectedAlert
      },
      .send(.dismissAlert) {
        $0.balanceAlert = nil
      }
    )
  }

  func testBalanceErrorLocalization() {
    let error = BalanceError.message("Error")
    XCTAssertEqual(error.localizedDescription, "Error")
  }
}
