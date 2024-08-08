import ComposableArchitecture
import SwiftUI

public struct BalanceView: View {
	public let store: StoreOf<BalanceReducer>

	public init(store: StoreOf<BalanceReducer>) {
		self.store = store
	}

  public var body: some View {
		WithViewStore(store, observe: {$0}) { viewStore in
			VStack {
				Text("Your total balance")
					.font(.body)
					.padding(.bottom, -20)
					.padding(.top, 10)
				HStack {
					Spacer()
					Text(viewStore.balance)
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
			// TODO: add alert to dismiss
			.onAppear {
				viewStore.send(.requestFetchBalance)
			}
		}
  }
}

//struct BalanceView_Previews: PreviewProvider {
//  public static let store: Store<BalanceReducer.State, BalanceReducer.Action> = .init(
//    initialState: .init(balance: ""),
//    reducer: BalanceReducer(),
//  )
//
//  static var previews: some View {
//    BalanceView(store: store)
//      .previewLayout(.sizeThatFits)
//  }
//}
