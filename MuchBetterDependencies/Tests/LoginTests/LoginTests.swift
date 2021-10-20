import ComposableArchitecture
@testable import LoginFeature
import XCTest

final class LoginTests: XCTestCase {
    func testLogin() {
        let store = TestStore(initialState: LoginState(token: ""),
                              reducer: loginReducer,
                              environment: LoginEnvironment.mock)

        let expected = "token from server"

        store.assert(
            .send(.login),
            .receive(.loginResponse(.success(expected))) {
                $0.token = expected
            }
        )
    }

    func testSpendError() {
        let failMock = LoginEnvironment.failing

        let store = TestStore(initialState: LoginState(token: ""),
                              reducer: loginReducer,
                              environment: failMock)

        let expected = LoginError.message("Login error")
        let expectedErrorAlert = AlertState(
            title: TextState("Error"),
            message: TextState("Login error"),
            buttons: [
                AlertState.Button.default(
                    TextState("Ok"),
                    action: AlertState.ButtonAction.send(LoginAction.dismissLoginAlert)
                ),
            ]
        )

        store.assert(
            .send(.login),
            .receive(.loginResponse(.failure(expected))) {
                $0.token = ""
                $0.alert = expectedErrorAlert
            }
        )
    }

    func testLoginErrorLocalization() {
        let error = LoginError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
