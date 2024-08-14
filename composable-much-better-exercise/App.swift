import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct MuchBetterApp: App {
  let store: StoreOf<AppReducer> = Store(
    initialState: .init(),
		reducer: {
			AppReducer()
				._printChanges()
		}
  )

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}
