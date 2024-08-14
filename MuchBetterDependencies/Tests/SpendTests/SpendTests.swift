import Common
import ComposableArchitecture
import SnapshotTesting

@testable import SpendFeature
import SwiftUI
import XCTest

@MainActor
final class SpendTests: XCTestCase {
	func testSpend() async {
		let store = TestStore(
			initialState: SpendReducer.State(),
			reducer: {
				SpendReducer()
			},
			withDependencies: {
				$0.spendClient = .previewValue
			}
		)
		
		let expectedAlert = AlertState<SpendReducer.Action.Alert>(
			title: TextState("Success"),
			message: TextState("Successfully created a new transactions"),
			dismissButton: .default(TextState("Ok"),
															action: .send(.dismiss))
		)
		
		await store
			.send(SpendReducer.Action.binding(.set(\.description, "Test description"))) {
				$0.description = "Test description"
			}
		await store
			.send(.binding(.set(\.amount, "111.11"))) {
				$0.amount = "111.11"
			}
		
		await store
			.send(.spendRequest)
		
		await store
			.receive(.spendResponse(.success("preview"))) {
				$0.description = ""
				$0.amount = ""
				$0.alert = expectedAlert
			}
	}
	
	func testFieldsEmptyResponse() async {
		let expectedAlert = AlertState<SpendReducer.Action.Alert>(
			title: TextState("Warning"),
			message: TextState("Description and amount fields are required"),
			dismissButton: .default(TextState("Ok"),
															action: .send(.dismiss))
		)
		
		let store = TestStore(
			initialState: .init(),
			reducer: {
				SpendReducer()
			},
		withDependencies: {
			$0.spendClient = .init(spendTransaction: { _ in
				throw SpendError.message("Error")
			})
		})
		
		await store
			.send(.spendRequest)
		
		await store
			.receive(.fieldsEmptyResponse) {
				$0.alert = expectedAlert
			}
		
		await store
			.send(.dismissAlert) {
				$0.alert = nil
			}
	}
	
	func testSpendFail() async {
		let expectedAlert = AlertState<SpendReducer.Action.Alert>(
			title: TextState("Error"),
			message: TextState("Error"),
			dismissButton: .default(TextState("Ok"),
															action: .send(.dismiss))
		)
		
		let store = TestStore(
			initialState: .init(
				description: "Legit transaction",
				amount: "100.01"
			),
			reducer: {
				SpendReducer()
			},
			withDependencies: {
				$0.spendClient = .init(spendTransaction: { _ in
					throw SpendError.message("Error")
				})
			}
		)
		
		let expected = SpendError.message("Error")
		
		await store
			.send(.spendRequest)
		
		await store
			.receive(.spendResponse(.failure(expected))) {
				$0.description = "Legit transaction"
				$0.amount = "100.01"
				$0.alert = expectedAlert
			}
	}
	
	func testSpendErrorLocalization() {
		let error = SpendError.message("Error")
		XCTAssertEqual(error.localizedDescription, "Error")
	}
}
