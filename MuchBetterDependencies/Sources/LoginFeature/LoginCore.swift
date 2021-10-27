//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Client
import ComposableArchitecture
import SwiftUI

public struct LoginState: Equatable {
    public var alert: AlertState<LoginAction>?
    public var email: String
    public var isEmailValid: Bool?
    public var password: String
    public var isPasswordValid: Bool?

    public init(email: String = "",
                password: String = "")
    {
        self.email = email
        self.password = password
    }
}

public enum LoginAction: Equatable {
    case logout
    case login
    case loginResponse(Result<String, LoginError>)
    case dismissAlert
    case dismissLoginAlert
    case emailValidate(String)
    case passwordValidate(String)
    case responseEmailValidate(Bool)
    case responsePasswordValidate(Bool)
}

public struct LoginEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var login: (String, String) -> Effect<Token, LoginError>
    public var logout: () -> Void

    public init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
                login: @escaping (String, String) -> Effect<Token, LoginError>,
                logout: @escaping () -> Void)
    {
        self.mainQueue = mainQueue
        self.login = login
        self.logout = logout
    }
}

public extension LoginEnvironment {
    static var mock: LoginEnvironment = .init(mainQueue: .immediate) { _, _ in
        Effect(value: "token from server")
    } logout: {}

    static var failing: LoginEnvironment = .init(mainQueue: .immediate) { _, _ in
        Effect(error: LoginError.message("Login error"))
    } logout: {}
}

public let loginReducer: Reducer<
    LoginState, LoginAction, LoginEnvironment
> =
    .init { state, action, environment in
        switch action {
        case let .loginResponse(.failure(error)):

            state.alert = .init(
                title: TextState("Error"),
                message: TextState(error.localizedDescription),
                dismissButton: .default(
                    TextState("Ok"),
                    action: .send(.dismissAlert)
                )
            )

            return .none

        case .logout:
            return Effect.fireAndForget {
                environment.logout()
            }
        case let .responseEmailValidate(isEmailValid):

            state.isEmailValid = isEmailValid

            return .none

        case let .responsePasswordValidate(isPasswordValid):

            state.isPasswordValid = isPasswordValid

            return .none

        case let .emailValidate(email):
            struct EmailCancelId: Hashable {}

            let isEmailValid = email.contains("@")

            return Effect(value: isEmailValid)
                .debounce(id: EmailCancelId(), for: 0.5, scheduler: environment.mainQueue)
                .map(LoginAction.responseEmailValidate)
                .eraseToEffect()

        case let .passwordValidate(password):
            struct PasswordCancelId: Hashable {}

            let isPasswordValid = password.count >= 6

            return Effect(value: isPasswordValid)
                .debounce(id: PasswordCancelId(), for: 0.5, scheduler: environment.mainQueue)
                .map(LoginAction.responsePasswordValidate)
                .eraseToEffect()

        case .dismissLoginAlert:

            state.alert = nil

            return .none

        case .login:

            return environment.login(state.email, state.password)
                .receive(on: environment.mainQueue)
                .mapError { LoginError.message($0.localizedDescription) }
                .catchToEffect()
                .map(LoginAction.loginResponse)

        case .loginResponse:

            return .none

        case .dismissAlert:

            state.alert = nil

            return .none
        }
    }
