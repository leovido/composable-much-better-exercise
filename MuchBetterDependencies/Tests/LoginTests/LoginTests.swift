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

        store.assert(
            .send(.login),
            .receive(.loginResponse(.failure(expected))) {
                $0.token = ""
            }
        )
    }

    func testLoginErrorLocalization() {
        let error = LoginError.message("Error")
        XCTAssertEqual(error.localizedDescription, "Error")
    }
}
