import Client
import ComposableArchitecture
import Foundation

extension LoginClient {
	static let liveValue: LoginClient = Self(
		login: { email, password in
			return Client.shared.login().description
		}, logout: {
			return ""
		}
	)
}
