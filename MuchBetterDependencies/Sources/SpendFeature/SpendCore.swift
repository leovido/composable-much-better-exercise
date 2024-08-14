//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Client
import Common
import ComposableArchitecture
import Foundation

@Reducer
public struct SpendReducer: Reducer {
	@ObservableState
	public struct State: Equatable {
		@Presents public var alert: AlertState<Action.Alert>?
		public var description: String
		public var amount: String
		
		public init(description: String = "", amount: String = "", alert: AlertState<Action.Alert>? = nil) {
			self.description = description
			self.amount = amount
			self.alert = alert
		}
	}
	
	public enum Action: Equatable, BindableAction {
		case binding(BindingAction<State>)
		case alert(PresentationAction<Alert>)
		case dismissAlert
		case spendRequest
		case spendResponse(Result<String, SpendError>)
		case fieldsEmptyResponse
		@CasePathable
		public enum Alert {
			case confirmButtonTapped
			case dismiss
		}
	}
	
	@Dependency(\.spendClient) var spendClient
	
	public init() {}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()

		Reduce { state, action in
			switch action {
				case .alert:
					return .none
				case .binding:
					return .none
				case let .spendResponse(.failure(error)):
					state.alert = AlertState(
						title: TextState("Error"),
						message: TextState(error.localizedDescription),
						dismissButton: .default(
							TextState("Ok"),
							action: .send(.dismiss)
						)
					)
					
					return .none
					
				case .fieldsEmptyResponse:
					state.alert = .init(
						title: TextState("Warning"),
						message: TextState("Description and amount fields are required"),
						dismissButton: .default(TextState("Ok"),
																		action: .send(.dismiss))
					)
					
					return .none
					
				case .spendRequest:
					struct SpendRequestCancellableId: Hashable {}
					
					guard !state.description.isEmpty, !state.amount.isEmpty
					else {
						return .run { send in
							await send(.fieldsEmptyResponse)
						}
					}
					
					let transaction = Transaction(date: Date(), description: state.description, amount: state.amount, currency: .gbp)
					
					return .run { send in
						let response = try await spendClient.spendTransaction(transaction)
						
						await send(.spendResponse(.success(response)))
					} catch: { error, send in
						await send(.spendResponse(.failure(.message(error.localizedDescription))))
					}
					.cancellable(id: SpendRequestCancellableId())
					
				case .spendResponse(.success):
					
					state.alert = AlertState(
						title: TextState("Success"),
						message: TextState("Successfully created a new transactions"),
						dismissButton: .default(
							TextState("Ok"),
							action: .send(.dismiss)
						)
					)
					
					state.description.removeAll()
					state.amount.removeAll()
					
					return .none
					
				case .dismissAlert:
					state.alert = nil
					return .none
			}
		}
			.ifLet(\.$alert, action: \.alert)
	}
}
