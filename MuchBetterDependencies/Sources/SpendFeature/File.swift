import Common
import ComposableArchitecture

public struct SpendClient {
	public var spendTransaction: @Sendable (Common.Transaction) async throws -> String
}

extension DependencyValues {
	var spendClient: SpendClient {
		get { self[SpendClient.self] }
		set { self[SpendClient.self] = newValue }
	}
}

extension SpendClient: DependencyKey {
	static public var previewValue: SpendClient = Self(spendTransaction: { _ in
		return "preview"
	})
	
	static public var testValue: SpendClient = Self(spendTransaction: { _ in
		return "test"
	})
}
