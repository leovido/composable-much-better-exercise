import Common
import ComposableArchitecture

@Reducer
public struct BalanceReducer {
	@ObservableState
	public struct State: Equatable {
		public var balanceAlert: AlertState<Action>?
		public var balance: String = ""
	}
	public enum Action: Equatable {
		case requestFetchBalance
		case responseReceiveFetchBalance(Result<Balance, BalanceError>)
		case dismissAlert
	}
	
	@Dependency(\.balanceClient) var balanceClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .responseReceiveFetchBalance(.failure(error)):
					
					state.balance = ""
					
					state.balanceAlert = .init(
						title: TextState("Error"),
						message: TextState(error.localizedDescription),
						dismissButton: .default(
							TextState("Ok"),
							action: .send(.dismissAlert)
						)
					)
					
					return .none
					
				case .dismissAlert:
					
					state.balanceAlert = nil
					
					return .none
					
				case .requestFetchBalance:
					fatalError()
					
				case let .responseReceiveFetchBalance(.success(balanceModel)):
					
					state.balance = MuchBetterNumberFormatter.formatCurrency(balanceModel)
					
					return .none
			}
		}
	}
}
