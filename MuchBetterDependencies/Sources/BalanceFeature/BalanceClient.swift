import Common
import ComposableArchitecture
import Client
import Foundation

@DependencyClient
public struct BalanceClient {
	var fetch: @Sendable () async throws -> BalanceModel
}

extension DependencyValues {
	var balanceClient: BalanceClient {
		get { self[BalanceClient.self] }
		set { self[BalanceClient.self] = newValue }
	}
}

extension BalanceClient: DependencyKey {
	static public let testValue = Self(
		fetch: {
			throw BalanceError.message("invalid")
		}
	)
	
	static public let previewValue: BalanceClient = Self(
		fetch: {
			return BalanceModel(balance: "111.11", currency: .gbp)
		}
	)
}
