import ComposableArchitecture
import XCTest
@testable import LoginFeature

final class LoginTests: XCTestCase {
  let scheduler = DispatchQueue.test

  func testLogin() {
    let store = TestStore(initialState: LoginState(),
                          reducer: loginReducer,
                          environment: LoginEnvironment.mock)

    let expected = "token from server"

    store.assert(
      .send(.login),
      .receive(.loginResponse(.success(expected)))
    )
  }

  func testLoginError() {
    let failMock = LoginEnvironment.failing

    let store = TestStore(initialState: LoginState(),
                          reducer: loginReducer,
                          environment: failMock)

    let expected = LoginError.message("Login error")
    let expectedAlert = AlertState(
      title: TextState("Error"),
      message: TextState("Login error"),
      dismissButton: .default(TextState("Ok"),
                              action: .send(LoginAction.dismissAlert))
    )

    store.assert(
      .send(.login),
      .receive(.loginResponse(.failure(expected))) {
        $0.alert = expectedAlert
      },
      .send(.dismissLoginAlert) {
        $0.alert = nil
      }
    )
  }

  func testEmailValidate() {
    let expectedEmail = "user@muchbetter.com"
    let store = TestStore(initialState: LoginState(email: expectedEmail),
                          reducer: loginReducer,
                          environment: LoginEnvironment.mock)

    store.assert(
      .send(LoginAction.emailValidate(expectedEmail)),
      .receive(.responseEmailValidate(true)) {
        $0.isEmailValid = true
      }
    )
  }

  func testEmailValidateFalse() {
    let expected = "invalidEmail"
    let store = TestStore(initialState: LoginState(email: expected),
                          reducer: loginReducer,
                          environment: LoginEnvironment.mock)

    store.assert(
      .send(LoginAction.emailValidate(expected)),
      .receive(.responseEmailValidate(false)) {
        $0.isEmailValid = false
      }
    )

    //	case let .passwordValidate(password):
    //		struct PasswordCancelId: Hashable {}
//
    //		let isPasswordValid = password.count >= 6
//
    //		return Effect(value: isPasswordValid)
    //			.debounce(id: PasswordCancelId(), for: 0.5, scheduler: RunLoop.main)
    //			.map(LoginAction.responsePasswordValidate)
    //			.eraseToEffect()
  }

  func testPasswordValidate() {
    let expectedPassword = "verylongpassword"
    let store = TestStore(initialState: LoginState(password: expectedPassword),
                          reducer: loginReducer,
                          environment: LoginEnvironment.mock)

    store.assert(
      .send(LoginAction.passwordValidate(expectedPassword)),
      .receive(.responsePasswordValidate(true)) {
        $0.isPasswordValid = true
      }
    )
  }

  func testPasswordValidateFalse() {
    let expectedPassword = "short"
    let store = TestStore(initialState: LoginState(password: expectedPassword),
                          reducer: loginReducer,
                          environment: LoginEnvironment.mock)

    store.assert(
      .send(LoginAction.passwordValidate(expectedPassword)),
      .receive(.responsePasswordValidate(false)) {
        $0.isPasswordValid = false
      }
    )
  }

  func testLogout() {
    let store = TestStore(initialState: LoginState(),
                          reducer: loginReducer,
                          environment: LoginEnvironment.mock)

    store.assert(
      .send(LoginAction.logout)
    )
  }

  func testLoginErrorLocalization() {
    let error = LoginError.message("Error")
    XCTAssertEqual(error.localizedDescription, "Error")
  }
}
