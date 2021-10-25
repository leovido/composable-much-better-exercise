//
//  AppUITests.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

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
            reducer: appReducer,
            environment: .mock
        )

        let appView = UIHostingController(rootView: AppView(store: store))

        assertSnapshot(matching: appView, as: .image(on: .iPhoneXsMax))
    }

    func testAppViewUILoggedIn() {
        let store = Store(
            initialState: .init(loginState: nil),
            reducer: appReducer,
            environment: .mock
        )

        let appView = UIHostingController(rootView: AppView(store: store))

        assertSnapshot(matching: appView, as: .image(on: .iPhoneXsMax))
    }
}
