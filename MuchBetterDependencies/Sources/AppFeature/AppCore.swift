import BalanceFeature
import Client
import Common
import ComposableArchitecture
import LoginFeature
import SpendFeature
import TransactionFeature

@Reducer
public struct AppReducer {
	@ObservableState
	public struct State: Equatable {
		public var balanceState: Balance.State
		public var transactionState: TransactionReducer.State
		public var spendState: SpendReducer.State
		public var loginState: Login.State?
		
		public init(
			balanceState: Balance.State = .init(),
			transactionState: TransactionReducer.State = .init(),
			spendState: SpendReducer.State = .init(),
			loginState: Login.State? = .init()
		) {
			self.balanceState = balanceState
			self.transactionState = transactionState
			self.spendState = spendState
			self.loginState = loginState
		}
	}
	
	public enum Action: Equatable {
		case balance(Balance.Action)
		case login(Login.Action)
		case spend(SpendReducer.Action)
		case transaction(TransactionReducer.Action)
		case logout
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.spendState, action: \.spend) {
			SpendReducer()
		}
		Scope(state: \.balanceState, action: \.balance) {
			Balance()
		}
		Scope(state: \.transactionState, action: \.transaction) {
			TransactionReducer()
		}
		Reduce { state, action in
			switch action {
				case .logout:
					state.loginState = Login.State()
					
					return .none
				case .balance:
					return .none
				case let .login(loginAction):
					switch loginAction {
						case .loginResponse(.success):
							
							state.loginState = nil
							
							return .none
						default:
							return .none
					}
				case .spend:
					return .none
				case .transaction:
					return .none
			}
		}
		.ifLet(\.loginState, action: \.login) {
			Login()
		}
	}
}

