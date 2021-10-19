//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import Foundation

public struct Transaction: Identifiable, Decodable, Hashable, AmountRepresentable {
    public let id: String
    public let date: Date
    public let description: String
    public let amount: String
    public let currency: Currency

    public init(id: String, date: Date, description: String, amount: String, currency: Currency) {
        self.id = id
        self.date = date
        self.description = description
        self.amount = amount
        self.currency = currency
    }
}
