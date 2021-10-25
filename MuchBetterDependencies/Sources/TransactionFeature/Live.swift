//
//  File.swift
//
//
//  Created by Christian Leovido on 25/10/2021.
//

import Client
import Common
import ComposableArchitecture
import Foundation

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
}
