import ComposableArchitecture
@testable import LoginFeature
import SnapshotTesting
import SwiftUI
import XCTest

final class LoginUITests: XCTestCase {
    func testLoginUIEmpty() {
        let store: Store<LoginState, LoginAction> = .init(
            initialState: .init(),
            reducer: .empty,
            environment: LoginEnvironment.mock
        )

        let loginView = UIHostingController(rootView: LoginView(store: store))

        assertSnapshot(matching: loginView, as: .image(on: .iPhoneXsMax))
    }

	func testLoginUIEmail() {
		let store: Store<LoginState, LoginAction> = .init(
			initialState: .init(email: "user@muchbetter.com"),
			reducer: .empty,
			environment: LoginEnvironment.mock
		)

		let loginView = UIHostingController(rootView: LoginView(store: store))

		assertSnapshot(matching: loginView, as: .image(on: .iPhoneXsMax))
	}

	func testLoginUIPassword() {
		let store: Store<LoginState, LoginAction> = .init(
			initialState: .init(password: "super-secure-password"),
			reducer: .empty,
			environment: LoginEnvironment.mock
		)

		let loginView = UIHostingController(rootView: LoginView(store: store))

		assertSnapshot(matching: loginView, as: .image(on: .iPhoneXsMax))
	}
}
