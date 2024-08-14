import ComposableArchitecture
import SwiftUI

public struct BalanceView: View {
	@Bindable public var store: StoreOf<Balance>
	
	public init(store: StoreOf<Balance>) {
		self.store = store
	}
	
	public var body: some View {
		WithPerceptionTracking {
			VStack {
				Text("Your total balance")
					.font(.body)
					.padding(.bottom, -20)
					.padding(.top, 10)
				HStack {
					Spacer()
					Text(store.balance)
						.font(.system(size: 50))
						.fontWeight(.bold)
						.padding()
					Spacer()
				}
			}
			.padding(.top, 10)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.orange, lineWidth: 1)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(
								LinearGradient(
									colors: [Color.orange.opacity(0.3),
													 Color.orange.opacity(1)],
									startPoint: .topLeading,
									endPoint: .bottomTrailing
								)
							)
					)
			)
			.padding()
//			.alert(
//				$store.scope(state: \.alert, action: \.alert)
//			)
			.onAppear {
				store.send(.requestFetchBalance)
			}
		}
	}
}

#Preview {
	BalanceView(store: .init(
		initialState: .init(),
		reducer: { Balance() }
	))
}
