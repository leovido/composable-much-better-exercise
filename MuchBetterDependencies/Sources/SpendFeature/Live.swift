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

extension SpendClient {
	public static let liveValue: SpendClient = Self(spendTransaction: { transaction in
    guard let transactionData = try? JSONEncoder.customEncoder.encode(transaction)
    else {
			throw SpendError.message("invalid")
    }

    guard let request = Client.shared.makeRequest(data: transactionData, endpoint: .spend, httpMethod: .POST)
    else {
			throw SpendError.message("invalid")
    }
		
		let (data, response) = try await URLSession.shared.data(for: request)

		guard let response = response as? HTTPURLResponse
		else {
			throw SpendError.message("invalid response")
		}
		
		guard (200 ... 299) ~= response.statusCode
		else {
			throw SpendError.message("Please make sure you have the right amount of available funds.")
		}
		
		return "success"
  })
}
