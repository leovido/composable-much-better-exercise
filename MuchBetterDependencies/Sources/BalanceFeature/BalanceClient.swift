import Common
import ComposableArchitecture
import Client
import Foundation

@DependencyClient
struct BalanceClient {
	var fetch: @Sendable () async throws -> BalanceModel
}

extension DependencyValues {
	var balanceClient: BalanceClient {
		get { self[BalanceClient.self] }
		set { self[BalanceClient.self] = newValue }
	}
}

extension BalanceClient: DependencyKey {
	static let testValue = Self(
		fetch: {
			throw BalanceError.message("invalid")
		}
	)
	
	static let previewValue: BalanceClient = Self(
		fetch: {
			return BalanceModel(balance: "111.11", currency: .gbp)
		}
	)
}
