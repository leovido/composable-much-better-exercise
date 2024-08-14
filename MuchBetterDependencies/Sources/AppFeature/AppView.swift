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
	public let store: StoreOf<AppReducer>

  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  public var body: some View {
		WithViewStore(store, observe: {$0}) { viewStore in
			if let st = store.scope(state: \.loginState, action: \.login) {
				LoginView(store: st)
			} else {
				TabView {
					NavigationView {
						VStack(alignment: .leading) {
							BalanceView(
								store: store.scope(
									state: \.balanceState,
									action: \.balance
								)
							)
							
							TransactionView(
								store: store.scope(
									state: \.transactionState,
									action: \.transaction
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
					
					SpendView(store: store.scope(
						state: \.spendState,
						action: \.spend)
					)
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

#Preview {
	Group {
		AppView(store: Store<AppReducer.State, AppReducer.Action>(
			initialState: AppReducer.State.init(),
			reducer: {
				AppReducer()
			}))
		AppView(store: .init(
			initialState: .init(loginState: nil),
			reducer: {
				AppReducer()
			}))
	}
	
}
