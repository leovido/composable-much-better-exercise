//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

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

public struct TransactionState: Equatable {
  public var transactionAlert: AlertState<TransactionAction>?
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

public enum TransactionAction: Equatable {
  case searchTextChanged(String)
  case fetchTransactions
  case receiveTransactions(Result<[Transaction], TransactionError>)
  case sortTransactions(TransactionSort)
  case dismissAlert
}

public struct TransactionEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var fetchTransactions: () -> Effect<[Transaction], TransactionError>

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    fetchTransactions: @escaping () -> Effect<[Transaction], TransactionError>
  ) {
    self.fetchTransactions = fetchTransactions
    self.mainQueue = mainQueue
  }
}

public extension TransactionEnvironment {
  static let mock: TransactionEnvironment = .init(
    mainQueue: .immediate,
    fetchTransactions: {
      Effect(value: [
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
      ])
    }
  )

  static let failing: TransactionEnvironment = .init(
    mainQueue: .immediate,
    fetchTransactions: {
      Effect(error: TransactionError.message("Error"))
    }
  )
}

public let transactionReducer: Reducer<
  TransactionState, TransactionAction, TransactionEnvironment
> =
  .init { state, action, environment in
    switch action {
    case let .receiveTransactions(.failure(error)):

      state.viewState = state.transactions.isEmpty ? .empty : .nonEmpty

      state.transactionAlert = .init(
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

      return environment.fetchTransactions()
        .receive(on: environment.mainQueue)
        .mapError { TransactionError.message($0.localizedDescription)
        }
        .catchToEffect()
        .map(TransactionAction.receiveTransactions)
        .eraseToEffect()

    case let .receiveTransactions(.success(newTransactions)):

      state.transactions = newTransactions
      state.filteredTransactions = newTransactions

      state.viewState = state.transactions.isEmpty ? .empty : .nonEmpty

      return Effect(value: state.sort)
        .map(TransactionAction.sortTransactions)
    }
  }
