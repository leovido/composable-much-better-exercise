//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Client
import Common
import ComposableArchitecture

public struct SpendState: Equatable {
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
    case spendRequest
    case spendResponse(Result<String, NSError>)
}

public struct SpendEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var spendTransaction: (Common.Transaction) -> Effect<String, Error>

    public init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
                spendTransaction: @escaping (Common.Transaction) -> Effect<String, Error>)
    {
        self.mainQueue = mainQueue
        self.spendTransaction = spendTransaction
    }
}

public extension SpendEnvironment {
    static let live: SpendEnvironment = .init { _ in
        guard let request = Client.shared.makeRequest(endpoint: .spend, httpMethod: .POST, headers: [:]) else {
            return .none
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .map { _ in "" }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

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
        case let .descriptionChanged(newDescription):

            state.description = newDescription

            return .none
        case let .amountChanged(newAmount):

            state.amount = newAmount

            return .none
        case .spendRequest:

            let transaction = Transaction(id: "", date: Date(), description: state.description, amount: state.amount, currency: .gbp)

            return environment.spendTransaction(transaction)
                .receive(on: environment.mainQueue)
                .mapError { $0 as NSError }
                .catchToEffect()
                .map(SpendAction.spendResponse)
                .eraseToEffect()
        case let .spendResponse(.success(response)):

            return .none

        case let .spendResponse(.failure(error)):

            return .none
        }
    }
