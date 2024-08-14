import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
	@Bindable public var store: StoreOf<Login>

	public init(store: StoreOf<Login>) {
    self.store = store
  }

  public var body: some View {
		WithPerceptionTracking {
      ProgressView("Logging you in...")
        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
				.transition(.opacity)
				.alert(
					$store.scope(state: \.alert, action: \.alert)
				)
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
