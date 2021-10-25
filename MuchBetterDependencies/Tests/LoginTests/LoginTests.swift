import ComposableArchitecture
@testable import LoginFeature
import XCTest

final class LoginTests: XCTestCase {
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
            }
        )
    }

    func testLoginErrorLocalization() {
        let error = LoginError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
