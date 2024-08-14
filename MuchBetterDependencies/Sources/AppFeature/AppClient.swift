import ComposableArchitecture

@DependencyClient
public struct AppClient {
	public var login: @Sendable () async throws -> String
	
	public init(login: @Sendable @escaping () -> String) {
		self.login = login
	}
}

extension DependencyValues {
	public var appClient: AppClient {
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
