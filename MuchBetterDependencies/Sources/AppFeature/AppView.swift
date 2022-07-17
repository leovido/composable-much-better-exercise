//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import BalanceFeature
import ComposableArchitecture
import LoginFeature
import SpendFeature
import SwiftUI
import TransactionFeature

public struct AppView: View {
  public let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

  public var body: some View {
    IfLetStore(store.scope(state: { $0.loginState },
                           action: AppAction.login)) { loginStore in
      LoginView(store: loginStore)
        .transition(.scale(scale: 2))
    } else: {
      WithViewStore(store) { viewStore in
        TabView {
          NavigationView {
            VStack(alignment: .leading) {
              BalanceView(
                store: store.scope(
                  state: { $0.balanceState },
                  action: AppAction.balance
                )
              )

              TransactionView(
                store: store.scope(
                  state: { $0.transactionState },
                  action: AppAction.transaction
                )
              )

              Spacer()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle(Text("Dashboard"))
            .toolbar(content: {
              Button {
                viewStore.send(.logout)
              } label: {
                Text("Logout")
              }

            })
          }
          .tabItem {
            Image(systemName: "house")
            Text("Dashboard")
          }

          SpendView(store: store.scope(state: { $0.spendState }, action: AppAction.spend))
            .toolbar(content: {
              Button {
                viewStore.send(.logout)
              } label: {
                Text("Logout")
              }

            })
            .tabItem {
              Image(systemName: "cart.badge.plus")
              Text("Spend")
            }
        }
        .accentColor(.orange)
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  public static let store: Store<AppState, AppAction> = .init(
    initialState: .init(loginState: LoginState()),
    reducer: appReducer,
    environment: AppEnvironment.mock
  )

  public static let withNoLoginStore: Store<AppState, AppAction> = .init(
    initialState: .init(loginState: nil),
    reducer: appReducer,
    environment: AppEnvironment.mock
  )

  static var previews: some View {
    Group {
      AppView(store: store)
      AppView(store: withNoLoginStore)
    }
  }
}
