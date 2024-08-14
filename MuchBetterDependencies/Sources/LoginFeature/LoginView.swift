import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
	@Bindable public var store: StoreOf<Login>
	
	public init(store: StoreOf<Login>) {
		self.store = store
	}
	
	public var body: some View {
		WithPerceptionTracking {
			if store.isLoading {
				ProgressView("Logging you in...")
					.progressViewStyle(CircularProgressViewStyle(tint: .orange))
					.transition(.opacity)
					.alert(
						$store.scope(state: \.alert, action: \.alert)
					)
			} else {
				VStack {
					Spacer()
					VStack {
						Text("MuchBetter app".uppercased())
							.font(.largeTitle)
							.fontWeight(.black)
						
						Text("with TCA (The Composable Architecture)")
							.font(.caption)
					}
					.padding(.bottom, 50)
					
					TextField("Email", text: $store.email,
										prompt: Text("user@muchbetter.com"))
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.background(Color.white)
					.keyboardType(.emailAddress)
					.autocapitalization(.none)
					
					SecureField("Password", text: $store.password,
											prompt: Text("········"))
					.textFieldStyle(RoundedBorderTextFieldStyle())
					
					Button(action: {
						store.send(.login)
					}, label: {
						Text("Login")
							.foregroundColor(Color.white)
					})
					.padding(10)
					.padding([.leading, .trailing], 15)
					.background(Color.orange)
					.clipShape(Capsule())
					.padding()
					
					Spacer()
				}
				.padding()
				.background(Color(UIColor.systemGray6))
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
