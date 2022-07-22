//
//  SwiftUIView.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import ComposableArchitecture
import SwiftUI

public struct BalanceView: View {
  public let store: Store<BalanceState, BalanceAction>

  public init(store: Store<BalanceState, BalanceAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
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
      .alert(
        self.store.scope(state: \.balanceAlert),
        dismiss: .dismissAlert
      )
      .onAppear {
        viewStore.send(.requestFetchBalance)
      }
    }
  }
}

struct BalanceView_Previews: PreviewProvider {
  public static let store: Store<BalanceState, BalanceAction> = .init(
    initialState: .init(balance: ""),
    reducer: balanceReducer,
    environment: BalanceEnvironment.mock
  )

  static var previews: some View {
    BalanceView(store: store)
      .previewLayout(.sizeThatFits)
  }
}
