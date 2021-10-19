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
    public var balance: String

    public init(balance: String) {
        self.balance = balance
    }
}

public enum BalanceAction: Equatable {
    case requestFetchBalance
    case responseReceiveFetchBalance(Result<Balance, BalanceError>)
}

public struct BalanceEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var fetchBalance: () -> Effect<Balance, Error>

    public init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
                fetchBalance: @escaping () -> Effect<Balance, Error>)
    {
        self.mainQueue = mainQueue
        self.fetchBalance = fetchBalance
    }
}

public extension BalanceEnvironment {
    static let live: BalanceEnvironment = .init {
        guard let request = Client.shared.makeRequest(endpoint: .balance, httpMethod: .GET, headers: [:]) else {
            return Effect(value: Balance(balance: "", currency: .gbp))
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .map {
                guard let response = $0.response as? HTTPURLResponse else {
                    return Data()
                }

                guard (200 ..< 399) ~= response.statusCode else {
                    return Data()
                }

                return $0.data
            }
            .decode(type: Balance.self, decoder: JSONDecoder())
            .mapError {
                $0 as Error
            }
            .eraseToEffect()
    }

    static var mock: BalanceEnvironment = .init(mainQueue: .immediate) {
        Effect(value: Balance(balance: "111.11", currency: .gbp))
    }

    static var failing: BalanceEnvironment = .init(mainQueue: .immediate) {
        Effect(error: BalanceError.message("Error"))
    }
}

public let balanceReducer: Reducer<BalanceState, BalanceAction, BalanceEnvironment> = .init { state, action, environment in
    switch action {
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

    case let .responseReceiveFetchBalance(.failure(error)):

        state.balance = ""

        return .none
    }
}
