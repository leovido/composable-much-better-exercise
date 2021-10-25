import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
@testable import SpendFeature

final class SpendUITests: XCTestCase {
    func testSpendViewUIEmpty() {
        let store: Store<SpendState, SpendAction> = .init(
            initialState: .init(),
            reducer: .empty,
            environment: SpendEnvironment.mock
        )

        let spendView = UIHostingController(rootView: SpendView(store: store))

        assertSnapshot(matching: spendView, as: .image(on: .iPhoneXsMax))
    }

    func testSpendViewUIDescription() {
        let store: Store<SpendState, SpendAction> = .init(
            initialState: .init(description: "TestUI description"),
            reducer: .empty,
            environment: SpendEnvironment.mock
        )

        let spendView = UIHostingController(rootView: SpendView(store: store))

        assertSnapshot(matching: spendView, as: .image(on: .iPhoneXsMax))
    }

    func testSpendViewUIAmount() {
        let store = Store(
            initialState: .init(amount: "111.11"),
            reducer: spendReducer,
            environment: .mock
        )

        let spendView = UIHostingController(rootView: SpendView(store: store))

        assertSnapshot(matching: spendView, as: .image(on: .iPhoneXsMax))
    }

    func testSpendViewUIDescriptionAndAmount() {
        let store = Store(
            initialState: .init(description: "TestUI description", amount: "111.11"),
            reducer: spendReducer,
            environment: .mock
        )

        let spendView = UIHostingController(rootView: SpendView(store: store))

        assertSnapshot(matching: spendView, as: .image(on: .iPhoneXsMax))
    }
}
