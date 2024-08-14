import ComposableArchitecture

@DependencyClient
public struct AppClient {
	public var login: () async throws -> String
}

extension DependencyValues {
	var appClient: AppClient {
		get { self[AppClient.self] }
		set { self[AppClient.self] = newValue}
	}
}

extension AppClient: DependencyKey {
	static public let previewValue: AppClient = .init {
		return "preview"
	}
	
	static public var testValue: AppClient = .init {
		return "test"
	}
}
