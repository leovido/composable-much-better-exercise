import ComposableArchitecture

@DependencyClient
struct LoginClient {
	var login: (String, String) async throws -> String = { _,_ in "" }
	var logout: () async throws -> String = { "" }
}

extension LoginClient: DependencyKey {
	static var previewValue: LoginClient = Self(
		login: { email, password in
			return "token from server"
		},
		logout: {
			return ""
		}
	)
	
	static var testValue: LoginClient = Self(
		login: { email, password in
			throw LoginError.message("Login error")
		},
		logout: {
			return ""
		}
	)
}

extension DependencyValues {
	var loginClient: LoginClient {
		get { self[LoginClient.self] }
		set { self[LoginClient.self] = newValue }
	}
}

