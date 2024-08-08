import Common
import ComposableArchitecture
import Client
import Foundation

@DependencyClient
struct BalanceClient {
	var fetch: @Sendable () async throws -> Balance
}

extension DependencyValues {
	var balanceClient: BalanceClient {
		get { self[BalanceClient.self] }
		set { self[BalanceClient.self] = newValue }
	}
}

extension BalanceClient: DependencyKey {
	static let liveValue = Self(
		fetch: {
			guard let request = Client.shared.makeRequest(endpoint: .balance, httpMethod: .GET)
			else {
				return Balance(balance: "", currency: .gbp)
			}
			
			let (data, response) = try await URLSession.shared.data(for: request)

			guard let response = response as? HTTPURLResponse,
						(200 ..< 399) ~= response.statusCode
			else {
				fatalError()
			}
			
			let d = try JSONDecoder().decode(Balance.self, from: data)

			return d
		}
	)
	
	/// This is the "unimplemented" fact dependency that is useful to plug into tests that you want
	/// to prove do not need the dependency.
	static let testValue = Self(
		fetch: {
			return Balance(balance: "111.11",
										 currency: .gbp)
		}
	)
}
