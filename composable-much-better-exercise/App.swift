//
//  composable_much_better_exerciseApp.swift
//  composable-much-better-exercise
//
//  Created by Christian Leovido on 12/10/2021.
//

import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct MuchBetterApp: App {
    let store: Store<AppState, AppAction> = Store(
        initialState: .init(),
        reducer: appReducer.debug(),
        environment: .live
    )

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
