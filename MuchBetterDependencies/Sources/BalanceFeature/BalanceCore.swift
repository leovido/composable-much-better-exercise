//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import Client
import Common
import ComposableArchitecture

public struct BalanceState: Equatable {
  public var balanceAlert: AlertState<BalanceAction>?
  public var balance: String

  public init(balance: String) {
    self.balance = balance
  }
}

public enum BalanceAction: Equatable {
  case requestFetchBalance
  case responseReceiveFetchBalance(Result<Balance, BalanceError>)
  case dismissAlert
}

public struct BalanceEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var fetchBalance: () -> Effect<Balance, Error>

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue> = .main,
    fetchBalance: @escaping () -> Effect<Balance, Error>
  ) {
    self.mainQueue = mainQueue
    self.fetchBalance = fetchBalance
  }
}

public extension BalanceEnvironment {
  static var mock: BalanceEnvironment = .init(mainQueue: .immediate) {
    Effect(value: Balance(balance: "111.11", currency: .gbp))
  }

  static var failing: BalanceEnvironment = .init(mainQueue: .immediate) {
    Effect(error: BalanceError.message("Error"))
  }
}

// swiftlint:disable line_length
public let balanceReducer: Reducer<BalanceState, BalanceAction, BalanceEnvironment> = .init { state, action, environment in
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

    return environment.fetchBalance()
      .receive(on: environment.mainQueue)
      .mapError {
        BalanceError.message($0.localizedDescription)
      }
      .catchToEffect()
      .map(BalanceAction.responseReceiveFetchBalance)
      .eraseToEffect()

  case let .responseReceiveFetchBalance(.success(balanceModel)):

    state.balance = MuchBetterNumberFormatter.formatCurrency(balanceModel)

    return .none
  }
}
