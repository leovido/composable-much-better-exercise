//
//  File.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

import Common
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest
@testable import BalanceFeature

final class BalanceUITests: XCTestCase {
  func testBalanceViewUIAmount() {
    let store = Store(
      initialState: .init(balance: "111.11"),
			reducer: {
				Balance()
			}
    )

    let balanceView = UIHostingController(rootView: BalanceView(store: store))

		assertSnapshot(of: balanceView, as: .image(on: .iPhoneXsMax))
  }
}
