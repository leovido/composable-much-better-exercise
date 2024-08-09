import ComposableArchitecture
import XCTest

@testable import LoginFeature

@MainActor
final class LoginTests: XCTestCase {
  func testLogin() async {
		let store = TestStore(initialState: Login.State(),
													reducer: {
			Login()
		}) {
			$0.loginClient = .previewValue
		}

		await store.send(.login)
		await store.receive(\.loginResponse)
  }

	func testLoginError() async {
		let failMock = LoginClient.testValue
		
		let store = TestStore(initialState: Login.State(),
													reducer: {
			Login()
		}) {
			$0.loginClient = failMock
		}
		
		let expectedAlert = AlertState<Login.Action.LoginAlert>(
      title: TextState("Error"),
      message: TextState("Login error"),
      dismissButton: .default(TextState("Ok"),
															action: .send(Login.Action.LoginAlert.dismiss))
    )

		await store.send(.login)
		await store.receive(\.loginResponse) {
			$0.alert = expectedAlert
		}

		await store.send(.alert(.dismiss)) {
			$0.alert = nil
		}
  }

  func testEmailValidate() async {
    let expectedEmail = "user@muchbetter.com"
		let store = TestStore(initialState: Login.State(),
													reducer: {
			Login()
		}) {
			$0.mainQueue = .immediate
			$0.loginClient = .testValue
		}
		
		await store.send(Login.Action.emailValidate(expectedEmail))
		
		await store.receive(\.responseEmailValidate) {
			$0.isEmailValid = true
		}
	}
	//
	func testEmailValidateFalse() async {
		let expected = "invalidEmail"
		let store = TestStore(initialState: Login.State(email: expected),
													reducer: {
			Login()
		}, withDependencies: {
			$0.mainQueue = .immediate
		})
		
		await store.send(Login.Action.emailValidate(expected))
		await store.receive(\.responseEmailValidate) {
			$0.isEmailValid = false
		}
  }

  func testPasswordValidate() async {
    let expectedPassword = "verylongpassword"
		let store = TestStore(initialState: Login.State(password: expectedPassword),
													reducer: {
			Login()
		}, withDependencies: {
			$0.mainQueue = .immediate
			$0.loginClient = .testValue
		})
		
		await store.send(.passwordValidate(expectedPassword))
		
		await store.receive(\.responsePasswordValidate) {
			$0.isPasswordValid = true
		}

  }

  func testPasswordValidateFalse() async {
		let expectedPassword = "short"
		let store = TestStore(initialState: Login.State(password: expectedPassword),
													reducer: {
			Login()
		}, withDependencies: {
			$0.mainQueue = .immediate
			$0.loginClient = .testValue
		})
		
		await store.send(.passwordValidate(expectedPassword))
		
		await store.receive(\.responsePasswordValidate) {
			$0.isPasswordValid = false
		}
  }

  func testLogout() async {
		let store = TestStore(initialState: Login.State(),
													reducer: {
			Login()
		}, withDependencies: {
			$0.mainQueue = .immediate
			$0.loginClient = .testValue
		})

		await store.send(.logout)
  }
//
//  func testLoginErrorLocalization() {
//    let error = LoginError.message("Error")
//    XCTAssertEqual(error.localizedDescription, "Error")
//  }
}
