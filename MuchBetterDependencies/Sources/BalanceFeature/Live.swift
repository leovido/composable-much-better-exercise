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

public extension BalanceEnvironment {
  static let live: BalanceEnvironment = .init {
    guard let request = Client.shared.makeRequest(endpoint: .balance, httpMethod: .GET)
    else {
      return Effect(value: Balance(balance: "", currency: .gbp))
    }

    return URLSession.shared.dataTaskPublisher(for: request)
      .receive(on: DispatchQueue.main)
      .map {
        guard let response = $0.response as? HTTPURLResponse
        else {
          return Data()
        }

        guard (200 ..< 399) ~= response.statusCode
        else {
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
}
