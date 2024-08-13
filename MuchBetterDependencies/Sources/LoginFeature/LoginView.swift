import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
	public let store: Store<Login.State, Login.Action>

	public init(store: Store<Login.State, Login.Action>) {
    self.store = store
  }

  public var body: some View {
		WithPerceptionTracking {
      ProgressView("Logging you in...")
        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
//				.alert(store: store)
        .onAppear {
          store.send(.login)
        }
    }
  }
}

#Preview {
	LoginView(store: .init(
		initialState: .init(),
		reducer: { Login() }
	))
}
