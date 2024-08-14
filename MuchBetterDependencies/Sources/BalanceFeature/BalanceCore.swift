import Common
import ComposableArchitecture

@Reducer
public struct Balance: Reducer {
	@ObservableState
	public struct State: Equatable {
		@Presents var alert: AlertState<Action.Alert>?
		var balance: String = ""
		
		public init(alert: AlertState<Action.Alert>? = nil, balance: String = "") {
			self.alert = alert
			self.balance = balance
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<State>)
		case requestFetchBalance
		case responseReceiveFetchBalance(Result<BalanceModel, BalanceError>)
		@CasePathable
		public enum Alert: Equatable {
			case dismiss
		}
	}
	
	@Dependency(\.balanceClient) var balanceClient
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .responseReceiveFetchBalance(.failure(error)):
					
					state.balance = ""
					
					state.alert = .init(
						title: TextState("Error"),
						message: TextState(error.localizedDescription),
						dismissButton: .default(
							TextState("Ok"),
							action: .send(.dismiss)
						)
					)
					
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
				case .alert:
					return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}
