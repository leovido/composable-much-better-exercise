import ComposableArchitecture
import SwiftUI

public struct TransactionView: View {
	public let store: StoreOf<TransactionReducer>
	
	public init(store: StoreOf<TransactionReducer>) {
		self.store = store
	}
	
	public var body: some View {
		WithPerceptionTracking {
			VStack {
				HStack {
					Text("Transactions")
						.font(.largeTitle)
						.fontWeight(.bold)
					Spacer()
					
					Menu {
						Button {
							store.send(.sortTransactions(.newToOld))
						} label: {
							Label("Sort by newest",
										systemImage: store.state.sort == .newToOld ? "checkmark.circle.fill" : "")
						}
						Button {
							store.send(.sortTransactions(.oldToNew))
						} label: {
							Label("Sort by oldest",
										systemImage: store.state.sort == .oldToNew ? "checkmark.circle.fill" : "")
						}
						Divider()
						Button {
							store.send(.sortTransactions(.lowHighPrice))
						} label: {
							Label("Price low/high",
										systemImage: store.state.sort == .lowHighPrice ? "checkmark.circle.fill" : "")
						}
						Button {
							store.send(.sortTransactions(.highLowPrice))
						} label: {
							Label("Price high/low",
										systemImage: store.state.sort == .highLowPrice ? "checkmark.circle.fill" : "")
						}
					} label: {
						Image(systemName: "line.3.horizontal.decrease.circle")
					}
					.padding(.trailing)
				}
				.padding([.top, .leading])
				
				if store.viewState == .nonEmpty {
					List(store.filteredTransactions) { transaction in
						HStack {
							VStack(alignment: .leading) {
								Text(transaction.description)
									.font(Font.system(size: 17, design: .rounded))
								Text(formatted(transaction.date))
									.font(.caption)
									.foregroundColor(Color(UIColor.systemGray))
							}
							Spacer()
							Text(transaction.amount)
								.font(Font.system(size: 17, weight: .bold, design: .rounded))
						}
					}
					.listStyle(InsetGroupedListStyle())
					.refreshable {
						store.send(.fetchTransactions)
					}
				} else if store.viewState == .loading {
					ProgressView("Refresing transactions...")
						.progressViewStyle(CircularProgressViewStyle(tint: .orange))
				} else if store.viewState == .empty {
					VStack {
						Spacer()
						Text("No transactions")
							.font(.headline)
							.fontWeight(.bold)
						Text("We haven't found any transactions. Fancy a treat?")
							.multilineTextAlignment(.center)
							.foregroundColor(Color(UIColor.systemGray))
							.padding(.top, 1)
							.padding([.leading, .trailing])
							.font(.caption)
						Spacer()
					}
				}
			}
			.background(Color(UIColor.systemGray6))
//			.searchable(
//				text: store.binding(
//					get: \.searchText,
//					send: { .searchTextChanged }
//				),
//				prompt: "Search transactions"
//			)
//			.alertfetchTransactions(
//				self.store.scope(state: \.transactionAlert),
//				dismiss: .dismissAlert
//			)
//			.onAppear {
//				store.send(.fetchTransactions)
//			}
		}
	}
	
	func formatted(_ date: Date) -> String {
		let dateFormatter: DateFormatter = .init()
		
		dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
		
		return dateFormatter.string(from: date)
	}
}

#Preview {
	TransactionView(store:
			.init(
				initialState: .init(),
				reducer: { TransactionReducer() },
				withDependencies: { deps in
					deps.transactionClient = .testValue
				}
			)
	)
}
