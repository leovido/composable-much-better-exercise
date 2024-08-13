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
	public struct State: Equatable {
		public var spendAlert: AlertState<Action>?
		public var description: String
		public var amount: String
		
		public init(description: String = "", amount: String = "") {
			self.description = description
			self.amount = amount
		}
	}
	
	public enum Action: Equatable {
		case descriptionChanged(String)
		case amountChanged(String)
		case dismissAlert
		case spendRequest
		case spendResponse(Result<String, NSError>)
		case fieldsEmptyResponse
	}
	
	@Dependency(\.spendClient) var spendClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .spendResponse(.failure(error)):
					
					state.spendAlert = AlertState(
						title: TextState("Error"),
						message: TextState(error.localizedDescription),
						dismissButton: .default(
							TextState("Ok"),
							action: .send(.dismissAlert)
						)
					)
					
					return .none
					
				case .fieldsEmptyResponse:
					
					state.spendAlert = .init(
						title: TextState("Warning"),
						message: TextState("Description and Amount fields are required"),
						dismissButton: .default(TextState("Ok"),
																		action: .send(.dismissAlert))
					)
					
					return .none
					
				case let .descriptionChanged(newDescription):
					
					state.description = newDescription
					
					return .none
					
				case let .amountChanged(newAmount):
					
					state.amount = newAmount
					
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
					}
					
				case .spendResponse(.success):
					
					state.spendAlert = AlertState(
						title: TextState("Success"),
						message: TextState("Successfully created a new transactions"),
						dismissButton: .default(
							TextState("Ok"),
							action: .send(.dismissAlert)
						)
					)
					
					state.description.removeAll()
					state.amount.removeAll()
					
					return .none
					
				case .dismissAlert:
					
					state.spendAlert = nil
					
					return .none
			}
		}
	}
}
