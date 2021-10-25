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
}

public struct TransactionState: Equatable {
    public var transactions: [Transaction]
    public var filteredTransactions: [Transaction] = []
    public var searchText: String
    public var sort: TransactionSort = .oldToNew

    public var viewState: TransactionViewState {
        transactions.isEmpty ? .empty : .nonEmpty
    }

    public init(transactions: [Transaction] = [],
                searchText: String = "")
    {
        self.transactions = transactions
        filteredTransactions = transactions
        self.searchText = searchText
    }
}

public enum TransactionAction: Equatable {
    case searchTextChanged(String)
    case fetchTransactions
    case receiveTransactions(Result<[Transaction], TransactionError>)
    case sortTransactions(TransactionSort)
}

public struct TransactionEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var fetchTransactions: () -> Effect<[Transaction], TransactionError>

    public init(mainQueue: AnySchedulerOf<DispatchQueue>,
                fetchTransactions: @escaping () -> Effect<[Transaction], TransactionError>)
    {
        self.fetchTransactions = fetchTransactions
        self.mainQueue = mainQueue
    }
}

public extension TransactionEnvironment {
    static let live: TransactionEnvironment = .init(
        mainQueue: .main,
        fetchTransactions: {
            guard let request = Client.shared.makeRequest(
                endpoint: .transactions,
                httpMethod: .GET
            ) else {
                return Effect(value: [])
            }

            return URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .map { data, response in
                    guard let response = response as? HTTPURLResponse else {
                        return Data()
                    }

                    guard (200 ..< 399) ~= response.statusCode else {
                        return Data()
                    }

                    return data
                }
                .decode(type: [Transaction].self, decoder: transactionDecoder)
                .map {
                    $0.map {
                        let amountFormatted = MuchBetterNumberFormatter.formatCurrency($0)

                        return Transaction(id: $0.id,
                                           date: $0.date,
                                           description: $0.description,
                                           amount: amountFormatted,
                                           currency: $0.currency)
                    }
                }
                .mapError { TransactionError.message($0.localizedDescription) }
                .eraseToEffect()
        }
    )

    static let mock: TransactionEnvironment = .init(
        mainQueue: .immediate,
        fetchTransactions: {
            Effect(value: [
                Transaction(id: UUID().uuidString, date: Date(), description: "Starbucks", amount: "£1233.12", currency: .gbp),
                Transaction(id: UUID().uuidString, date: Date(), description: "Casumo casino", amount: "£1000.00", currency: .gbp),
                Transaction(id: UUID().uuidString, date: Date(), description: "Horse bet", amount: "£50.00", currency: .gbp),
                Transaction(id: UUID().uuidString, date: Date(), description: "Betfair casino", amount: "£200.00", currency: .gbp),
                Transaction(id: UUID().uuidString, date: Date(), description: "Description", amount: "£1233.12", currency: .gbp),
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

            guard !newSearchText.isEmpty else {
                state.searchText = ""
                state.filteredTransactions = state.transactions

                return .none
            }

            state.searchText = newSearchText
            state.filteredTransactions = state.transactions.filter { $0.description.fuzzyMatch(newSearchText)
            }

            return .none

        case .fetchTransactions:

            return environment.fetchTransactions()
                .receive(on: environment.mainQueue)
                .mapError { TransactionError.message($0.localizedDescription) }
                .catchToEffect()
                .map(TransactionAction.receiveTransactions)
                .eraseToEffect()

        case let .receiveTransactions(.success(newTransactions)):

            state.transactions = newTransactions
            state.filteredTransactions = newTransactions

            return Effect(value: state.sort)
                .map(TransactionAction.sortTransactions)

        case let .receiveTransactions(.failure(error)):

            return .none
        }
    }
