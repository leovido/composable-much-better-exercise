//
//  AppUITests.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

@testable import AppFeature
import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

final class AppUITests: XCTestCase {
    func testAppViewUI() {
        let store = Store(
            initialState: .init(),
            reducer: appReducer,
            environment: .mock
        )

        let appView = UIHostingController(rootView: AppView(store: store))

        assertSnapshot(matching: appView, as: .image(on: .iPhoneXsMax))
    }
}
