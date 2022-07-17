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

public extension SpendEnvironment {
  static let live: SpendEnvironment = .init { transaction in
    guard let data = try? JSONEncoder.customEncoder.encode(transaction)
    else {
      return .none
    }

    guard let request = Client.shared.makeRequest(data: data, endpoint: .spend, httpMethod: .POST)
    else {
      return .none
    }

    return URLSession.shared.dataTaskPublisher(for: request)
      .receive(on: DispatchQueue.main)
      .tryFilter { _, response in
        guard let response = response as? HTTPURLResponse
        else {
          return false
        }

        guard (200 ... 299) ~= response.statusCode
        else {
          throw SpendError.message("Please make sure you have the right amount of available funds.")
        }

        return true
      }
      .map { _ in "" }
      .mapError { $0 as NSError }
      .eraseToEffect()
  }
}
