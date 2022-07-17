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

public struct SpendState: Equatable {
  public var spendAlert: AlertState<SpendAction>?
  public var description: String
  public var amount: String

  public init(description: String = "", amount: String = "") {
    self.description = description
    self.amount = amount
  }
}

public enum SpendAction: Equatable {
  case descriptionChanged(String)
  case amountChanged(String)
  case dismissAlert
  case spendRequest
  case spendResponse(Result<String, NSError>)
  case fieldsEmptyResponse
}

public struct SpendEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var spendTransaction: (Common.Transaction) -> Effect<String, Error>

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue> = .main,
    spendTransaction: @escaping (Common.Transaction) -> Effect<String, Error>
  ) {
    self.mainQueue = mainQueue
    self.spendTransaction = spendTransaction
  }
}

public extension SpendEnvironment {
  static let mock: SpendEnvironment = .init(mainQueue: .immediate) { _ in
    Effect(value: "")
  }

  static let failing: SpendEnvironment = .init(mainQueue: .immediate) { _ in
    Effect(error: SpendError.message("Error"))
  }
}

public let spendReducer: Reducer<SpendState, SpendAction, SpendEnvironment> =
  .init { state, action, environment in
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
        return Effect(value: SpendAction.fieldsEmptyResponse)
      }

      let transaction = Transaction(date: Date(), description: state.description, amount: state.amount, currency: .gbp)

      return environment.spendTransaction(transaction)
        .cancellable(id: SpendRequestCancellableId())
        .receive(on: environment.mainQueue)
        .mapError { $0 as NSError }
        .catchToEffect()
        .map(SpendAction.spendResponse)
        .eraseToEffect()

    case let .spendResponse(.success(response)):

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
