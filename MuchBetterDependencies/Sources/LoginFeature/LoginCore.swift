import Client
import ComposableArchitecture
import SwiftUI

@Reducer
public struct Login: Reducer {
	@ObservableState
	public struct State: Equatable {
		@Presents var alert: AlertState<Action.LoginAlert>?
		var email: String = ""
		var isEmailValid: Bool?
		var password: String = ""
		var isPasswordValid: Bool?
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<LoginAlert>)
		case logout
		case login
		case loginResponse(Result<String, LoginError>)
		case dismissAlert
		case dismissLoginAlert
		case emailValidate(String)
		case passwordValidate(String)
		case responseEmailValidate(Bool)
		case responsePasswordValidate(Bool)
		
		@CasePathable
		public enum LoginAlert: Equatable {
			case dismiss
		}
	}
	
	@Dependency(\.mainQueue) var mainQueue
	@Dependency(\.loginClient) var loginClient
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case let .loginResponse(.failure(error)):
				
				state.alert = .init(
					title: TextState("Error"),
					message: TextState(error.localizedDescription),
					dismissButton: .default(
						TextState("Ok"),
						action: .send(.dismiss)
					)
				)
				
				return .none
				
			case .logout:
				return .run { send in
					_ = try await loginClient.logout()
				}
			case let .responseEmailValidate(isEmailValid):
				
				state.isEmailValid = isEmailValid
				
				return .none
				
			case let .responsePasswordValidate(isPasswordValid):
				
				state.isPasswordValid = isPasswordValid
				
				return .none
				
			case let .emailValidate(email):
				struct EmailCancelId: Hashable {}
				
				let isEmailValid = email.contains("@")
				
				return .run { send in
					await send(.responseEmailValidate(isEmailValid))
				}
				.debounce(id: EmailCancelId(), for: 0.5, scheduler: self.mainQueue)
				
			case let .passwordValidate(password):
				struct PasswordCancelId: Hashable {}
				
				let isPasswordValid = password.count >= 6
				
				return .run { send in
					await send(.responsePasswordValidate(isPasswordValid))
				}
				.debounce(id: PasswordCancelId(), for: 0.5, scheduler: self.mainQueue)
				
			case .dismissLoginAlert:
				state.alert = nil
				
				return .none
				
			case .login:
				let email = state.email
				let password = state.password
				return .run { send in
					let token = try await loginClient.login(email, password)
					
					// Simulate a login wait time of 2 seconds
					try await Task.sleep(nanoseconds: 2_000_000_000)
					
					await send(.loginResponse(.success(token)))
				} catch: { error, send in
					await send(.loginResponse(.failure(.message(error.localizedDescription))))
				}
				
			case .loginResponse:
				return .none
				
			case .dismissAlert:
				state.alert = nil
				
				return .none
			case .alert:
				return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}
