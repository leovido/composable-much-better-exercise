import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
@testable import AppFeature

final class AppUITests: XCTestCase {
  func testAppViewUI_Initial() {
    let store = Store(
      initialState: .init(),
			reducer: {
				AppReducer()
			},
			withDependencies: {
				$0.appClient = .previewValue
			}
    )

    let appView = UIHostingController(rootView: AppView(store: store))

    assertSnapshot(of: appView, as: .image(on: .iPhoneXsMax))
  }

  func testAppViewUILoggedIn() {
		let store = Store(
			initialState: .init(),
			reducer: {
				AppReducer()
			},
			withDependencies: {
				$0.appClient = .previewValue
			}
		)

    let appView = UIHostingController(rootView: AppView(store: store))

		assertSnapshot(of: appView, as: .image(on: .iPhoneXsMax))
  }
}
