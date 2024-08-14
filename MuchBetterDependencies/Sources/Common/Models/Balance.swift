//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import Foundation

public enum Currency: String, Codable, Hashable {
  case gbp = "GBP"
}

extension Currency: CustomStringConvertible {
  public var description: String {
    switch self {
    case .gbp:
      return "£"
    }
  }
}

public protocol AmountRepresentable {
  var amount: String { get }
  var currency: Currency { get }
}

public struct BalanceModel: Hashable, Decodable {
  public let balance: String
  public var currency: Currency

  public init(balance: String, currency: Currency) {
    self.balance = balance
    self.currency = currency
  }
}

extension BalanceModel: AmountRepresentable {
  public var amount: String {
    balance
  }
}
