import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
@testable import LoginFeature

final class LoginUITests: XCTestCase {
    func testLoginUI() {
        let store: Store<LoginState, LoginAction> = .init(
            initialState: .init(),
            reducer: .empty,
            environment: LoginEnvironment.mock
        )

        let loginView = UIHostingController(rootView: LoginView(store: store))

        assertSnapshot(matching: loginView, as: .image(on: .iPhoneXsMax))
    }
}
