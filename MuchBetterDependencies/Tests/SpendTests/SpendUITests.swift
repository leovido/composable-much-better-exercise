import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
@testable import SpendFeature

final class SpendUITests: XCTestCase {
  func testSpendViewUIEmpty() {
    let store: StoreOf<SpendReducer> = .init(
      initialState: .init(),
			reducer: {
				SpendReducer()
			},
			withDependencies: {
				$0.spendClient = .testValue
			}
    )

    let spendView = UIHostingController(rootView: SpendView(store: store))

    assertSnapshot(of: spendView, as: .image(on: .iPhoneXsMax))
  }

  func testSpendViewUIDescription() {
    let store: StoreOf<SpendReducer> = .init(
      initialState: .init(description: "TestUI description"),
			reducer: {
				SpendReducer()
			},
			withDependencies: {
				$0.spendClient = .testValue
			}
    )

    let spendView = UIHostingController(rootView: SpendView(store: store))

    assertSnapshot(of: spendView, as: .image(on: .iPhoneXsMax))
  }

  func testSpendViewUIAmount() {
    let store = Store(
      initialState: .init(amount: "111.11"),
			reducer: {
				SpendReducer()
			},
			withDependencies: {
				$0.spendClient = .testValue
			}
    )

    let spendView = UIHostingController(rootView: SpendView(store: store))

    assertSnapshot(of: spendView, as: .image(on: .iPhoneXsMax))
  }

  func testSpendViewUIDescriptionAndAmount() {
    let store = Store(
      initialState: .init(description: "TestUI description", amount: "111.11"),
			reducer: {
				SpendReducer()
			},
			withDependencies: {
				$0.spendClient = .testValue
			}
    )

    let spendView = UIHostingController(rootView: SpendView(store: store))

		assertSnapshot(of: spendView, as: .image(on: .iPhoneXsMax))
  }
}
