import Client
import Common
import ComposableArchitecture
import Foundation

public enum TransactionSort {
	case highLowPrice
	case lowHighPrice
	case newToOld
	case oldToNew
}

public enum TransactionViewState: String {
	case empty
	case nonEmpty
	case loading
}

@Reducer
public struct TransactionReducer {
	@ObservableState
	public struct State: Equatable {
		public var transactionAlert: AlertState<Action>?
		public var transactions: [Transaction]
		public var filteredTransactions: [Transaction] = []
		public var searchText: String
		public var sort: TransactionSort
		
		public var viewState: TransactionViewState
		
		public init(
			transactions: [Transaction] = [],
			searchText: String = "",
			viewState: TransactionViewState = .empty,
			sort: TransactionSort = .oldToNew
		) {
			self.transactions = transactions
			filteredTransactions = transactions
			self.searchText = searchText
			self.viewState = viewState
			self.sort = sort
		}
	}
	
	public enum Action: Equatable {
		case searchTextChanged(String)
		case fetchTransactions
		case receiveTransactions(Result<[Transaction], TransactionError>)
		case sortTransactions(TransactionSort)
		case dismissAlert
	}
	
	@Dependency(\.transactionClient) var transactionClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case let .receiveTransactions(.failure(error)):
				
				state.viewState = state.transactions.isEmpty ? .empty : .nonEmpty
				
				state.transactionAlert = AlertState(
					title: TextState("Error"),
					message: TextState(error.localizedDescription),
					dismissButton: .default(
						TextState("Ok"),
						action: .send(.dismissAlert)
					)
				)
				
				return .none
				
			case .dismissAlert:
				
				state.transactionAlert = nil
				
				return .none
				
			case let .sortTransactions(newSort):
				
				state.sort = newSort
				
				switch newSort {
				case .highLowPrice:
					let sortedTransactions = state.transactions.sorted(by: {
						MuchBetterNumberFormatter.number(from: $0.amount) > MuchBetterNumberFormatter.number(from: $1.amount)
					})
					state.filteredTransactions = sortedTransactions
					
					return .none
				case .lowHighPrice:
					let sortedTransactions = state.transactions.sorted(by: {
						MuchBetterNumberFormatter.number(from: $0.amount) < MuchBetterNumberFormatter.number(from: $1.amount)
					})
					state.filteredTransactions = sortedTransactions
					
					return .none
				case .newToOld:
					
					let sortedTransactions = state.transactions.sorted(by: { $0.date > $1.date })
					state.filteredTransactions = sortedTransactions
					
					return .none
				case .oldToNew:
					
					let sortedTransactions = state.transactions.sorted(by: { $0.date < $1.date })
					state.filteredTransactions = sortedTransactions
					
					return .none
				}
				
			case let .searchTextChanged(newSearchText):
				
				guard !newSearchText.isEmpty
				else {
					state.searchText = ""
					state.filteredTransactions = state.transactions
					
					return .none
				}
				
				state.searchText = newSearchText
				state.filteredTransactions = state.transactions.filter { $0.description.fuzzyMatch(newSearchText) }
				
				return .none
				
			case .fetchTransactions:
				
				state.viewState = .loading
				
				return .run { send in
					let transactions = try await transactionClient.fetchTransactions()
					
					await send(.receiveTransactions(.success(transactions)))
					return
				} catch: { error, send in
					await send(.receiveTransactions(.failure(.message(error.localizedDescription))))
				}
				
			case let .receiveTransactions(.success(newTransactions)):
				
				state.transactions = newTransactions
				state.filteredTransactions = newTransactions
				
				state.viewState = state.transactions.isEmpty ? .empty : .nonEmpty
				
				let sortedTransactions = state.sort
				
				return .run { send in
					await send(.sortTransactions(sortedTransactions))
				}
			}
		}
	}
}

@DependencyClient
public struct TransactionClient {
	public var fetchTransactions: @Sendable () async throws -> [Transaction]
}

extension DependencyValues {
	var transactionClient: TransactionClient {
		get { self[TransactionClient.self] }
		set { self[TransactionClient.self] = newValue }
	}
}

extension TransactionClient: DependencyKey {
	public static let testValue: TransactionClient = Self(
		fetchTransactions: {
			return [
				Transaction(id: UUID().uuidString, date: Date(),
										description: "Starbucks", amount: "£1233.12", currency: .gbp),
				Transaction(id: UUID().uuidString, date: Date(),
										description: "Casumo casino", amount: "£1000.00", currency: .gbp),
				Transaction(id: UUID().uuidString, date: Date(),
										description: "Horse bet", amount: "£50.00", currency: .gbp),
				Transaction(id: UUID().uuidString, date: Date(),
										description: "Betfair casino", amount: "£200.00", currency: .gbp),
				Transaction(id: UUID().uuidString, date: Date(),
										description: "Description", amount: "£1233.12", currency: .gbp),
			]
		}
	)
	
	public static let previewValue: TransactionClient = Self(
		fetchTransactions: {
			throw TransactionError.message("Error")
		}
	)
}
