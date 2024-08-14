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
		let expectedAlert = AlertState<Balance.Action.Alert>(
      title: TextState("Error"),
      message: TextState("invalid"),
      dismissButton: .default(TextState("Ok"),
															action: .send(.dismiss))
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
			$0.alert = expectedAlert
		}
		
		await store.send(.alert(.dismiss)) {
			$0.alert = nil
		}
  }

  func testBalanceErrorLocalization() {
    let error = BalanceError.message("Error")
    XCTAssertEqual(error.localizedDescription, "Error")
  }
}
