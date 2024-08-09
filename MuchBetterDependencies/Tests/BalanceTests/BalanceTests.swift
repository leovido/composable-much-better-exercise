import Common
import ComposableArchitecture
import XCTest

@testable import BalanceFeature

@MainActor
final class BalanceTest: XCTestCase {
	
	@MainActor
  func testFetchBalance() async {
		let store = TestStore(initialState: Balance.State(balance: "£111.11"), reducer: {
			Balance()
		}, withDependencies: {
			$0.balanceClient = BalanceClient.previewValue
		})
		
    let expected = BalanceModel(balance: "111.11", currency: .gbp)
		await store.send(Balance.Action.requestFetchBalance)
		await store.receive(Balance.Action.responseReceiveFetchBalance(.success(expected)))
  }

  func testFetchBalanceFail() async {
		let failMock = BalanceClient.testValue
    let expectedAlert = AlertState(
      title: TextState("Error"),
      message: TextState("invalid"),
      dismissButton: .default(TextState("Ok"),
															action: .send(Balance.Action.dismissAlert))
    )

		let store = TestStore(initialState: Balance.State(balance: "111.11"), 
													reducer: {
			Balance()
		}, withDependencies: {
			$0.balanceClient = failMock
		})
		store.exhaustivity = .off(showSkippedAssertions: true)
		
		let expected = BalanceError.message("invalid")

		await store.send(Balance.Action.requestFetchBalance)
		await store.receive(Balance.Action.responseReceiveFetchBalance(.failure(expected))) {
			$0.balanceAlert = expectedAlert
		}
		
		await store.send(Balance.Action.dismissAlert) {
			$0.balanceAlert = nil
		}
  }

  func testBalanceErrorLocalization() {
    let error = BalanceError.message("Error")
    XCTAssertEqual(error.localizedDescription, "Error")
  }
}
