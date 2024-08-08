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
