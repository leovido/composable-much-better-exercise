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
    public var password: String

    public init(email: String = "",
                password: String = "")
    {
        self.email = email
        self.password = password
    }
}

public enum LoginAction: Equatable {
    case login
    case loginResponse(Result<String, LoginError>)
    case dismissAlert
}

public struct LoginEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var login: (String, String) -> Effect<Token, LoginError>

    public init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
                login: @escaping (String, String) -> Effect<Token, LoginError>)
    {
        self.mainQueue = mainQueue
        self.login = login
    }
}

public extension LoginEnvironment {
    static let live: LoginEnvironment = .init { _, _ in
        Client.shared.login()
            .mapError { LoginError.message($0.localizedDescription) }
            .eraseToEffect()
    }

    static var mock: LoginEnvironment = .init(mainQueue: .immediate) { _, _ in
        Effect(value: "token from server")
    }

    static var failing: LoginEnvironment = .init(mainQueue: .immediate) { _, _ in
        Effect(error: LoginError.message("Login error"))
    }
}

public let loginReducer: Reducer<
    LoginState, LoginAction, LoginEnvironment
> =
    .init { state, action, environment in
        switch action {
        case let .loginResponse(.failure(error)):

            state.alert = .init(
                title: TextState(""),
                message: TextState(""),
                dismissButton: .default(
                    TextState("Ok"),
                    action: .send(.dismissAlert)
                )
            )

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
