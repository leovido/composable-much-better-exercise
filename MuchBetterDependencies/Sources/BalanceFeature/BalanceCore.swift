import Common
import ComposableArchitecture

@Reducer
public struct Balance: Reducer {
	@ObservableState
	public struct State: Equatable {
		var balanceAlert: AlertState<Action>?
		var balance: String = ""
	}
	
	public enum Action: Equatable {
		case requestFetchBalance
		case responseReceiveFetchBalance(Result<BalanceModel, BalanceError>)
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
				
				return .run { send in
					let balance = try await balanceClient.fetch()
					
					await send(.responseReceiveFetchBalance(.success(balance)))
				} catch: { error, send in
					await send(.responseReceiveFetchBalance(.failure(.message(error.localizedDescription))))
				}
				
				
			case let .responseReceiveFetchBalance(.success(balanceModel)):
				
				state.balance = MuchBetterNumberFormatter.formatCurrency(balanceModel)
				
				return .none
			}
		}
	}
}
