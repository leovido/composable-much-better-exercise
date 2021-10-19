//
//  SwiftUIView.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import ComposableArchitecture
import SwiftUI

public struct TransactionView: View {
    public let store: Store<TransactionState, TransactionAction>

    public init(store: Store<TransactionState, TransactionAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text("Transactions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()

                    Menu {
                        Button {
                            viewStore.send(.sortTransactions(.newToOld))
                        } label: {
                            Label("Sort by newest", systemImage: "")
                        }
                        Button {
                            viewStore.send(.sortTransactions(.oldToNew))
                        } label: {
                            Label("Sort by oldest", systemImage: "")
                        }
                        Divider()
                        Button {
                            viewStore.send(.sortTransactions(.lowHighPrice))
                        } label: {
                            Label("Price low/high", systemImage: "")
                        }
                        Button {
                            viewStore.send(.sortTransactions(.highLowPrice))
                        } label: {
                            Label("Price high/low", systemImage: "")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .padding(.trailing)
                }
                .padding([.top, .leading])

                if viewStore.viewState == .nonEmpty {
                    List(viewStore.filteredTransactions) { transaction in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.description)
                                    .font(Font.system(size: 17, design: .serif))
                                Text(formatted(transaction.date))
                                    .font(.caption)
                            }
                            Spacer()
                            Text(transaction.amount)
                                .font(Font.system(size: 17, weight: .bold, design: .rounded))
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    VStack {
                        Text("No transactions")
                            .fontWeight(.bold)
                        Text("We haven't found any transactions. Why not spend on a treat?")
                            .font(.caption)
                    }
                }
            }
            .background(Color(UIColor.systemGray6))
            .searchable(
                text: viewStore.binding(
                    get: { $0.searchText },
                    send: TransactionAction.searchTextChanged
                ),
                prompt: "Search transactions"
            )
            .onAppear {
                viewStore.send(.fetchTransactions)
            }
        }
    }

    func formatted(_ date: Date) -> String {
        let df: DateFormatter = .init()

        df.dateFormat = "dd/MM/yyyy HH:mm"

        return df.string(from: date)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static let store: Store<TransactionState, TransactionAction> = .init(
        initialState: .init(),
        reducer: transactionReducer,
        environment: .mock
    )

    static var previews: some View {
        TransactionView(store: store)
    }
}
