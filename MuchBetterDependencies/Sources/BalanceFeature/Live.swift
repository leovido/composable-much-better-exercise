import Common
import ComposableArchitecture
import Client
import Foundation

extension BalanceClient {
	static let liveValue = Self(
		fetch: {
			guard let request = Client.shared.makeRequest(endpoint: .balance, httpMethod: .GET)
			else {
				throw BalanceError.message("Invalid")
			}
			
			let (data, response) = try await URLSession.shared.data(for: request)
			let result = try JSONDecoder().decode(BalanceModel.self, from: data)
			
			return result
		}
	)
}
