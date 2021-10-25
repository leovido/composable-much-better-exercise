//
//  SwiftUIView.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import ComposableArchitecture
import SwiftUI

public struct SpendView: View {
    public let store: Store<SpendState, SpendAction>

    public init(store: Store<SpendState, SpendAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Form {
                        Section {
                            TextField(
                                "Description", text: viewStore.binding(
                                    get: { $0.description },
                                    send: SpendAction.descriptionChanged
                                )
                            )
                            .autocapitalization(.sentences)
                            .disableAutocorrection(true)

                            TextField(
                                "Amount", text: viewStore.binding(
                                    get: { $0.amount },
                                    send: SpendAction.amountChanged
                                )
                            )
                            .keyboardType(.decimalPad)
                        } header: {
                            Text("TRANSACTION DETAILS")
                        }
                        Section {
                            Button {
                                viewStore.send(.spendRequest)
                            } label: {
                                Text("Create transaction")
                            }
                        }
                    }

                    Spacer()
                }
                .background(Color(UIColor.systemGray6))
                .navigationTitle(Text("Spend"))
                .alert(
                    self.store.scope(state: \.spendAlert),
                    dismiss: .dismissAlert
                )
            }
        }
    }
}
