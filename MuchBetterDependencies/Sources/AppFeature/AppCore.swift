//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import BalanceFeature
import Client
import Common
import ComposableArchitecture
import LoginFeature
import SpendFeature
import TransactionFeature

public struct AppState: Equatable {
    public var balanceState: BalanceState
    public var transactionState: TransactionState
    public var spendState: SpendState
    public var loginState: LoginState?

    public init(balanceState: BalanceState = .init(balance: ""),
                transactionState: TransactionState = .init(),
                spendState: SpendState = .init(),
                loginState: LoginState? = .init())
    {
        self.balanceState = balanceState
        self.transactionState = transactionState
        self.spendState = spendState
        self.loginState = loginState
    }
}

public enum AppAction: Equatable {
    case balance(BalanceAction)
    case login(LoginAction)
    case spend(SpendAction)
    case transaction(TransactionAction)
    case logout
}

public struct AppEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var login: () -> Effect<String, Error>

    public init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
                login: @escaping () -> Effect<String, Error>)
    {
        self.mainQueue = mainQueue
        self.login = login
    }
}

public extension AppEnvironment {
    static let live: AppEnvironment = .init(login: {
        Client.shared.login()
            .eraseToEffect()
    })
    static let mock: AppEnvironment = .init(login: {
        Effect.fireAndForget {}
    })
}

public let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    loginReducer
        .optional()
        .pullback(
            state: \.loginState,
            action: /AppAction.login,
            environment: { _ in
                LoginEnvironment.live
            }
        ),
    balanceReducer
        .pullback(
            state: \.balanceState,
            action: /AppAction.balance,
            environment: { _ in
                BalanceEnvironment.live
            }
        ),
    transactionReducer
        .pullback(
            state: \.transactionState,
            action: /AppAction.transaction,
            environment: { _ in
                TransactionEnvironment.live
            }
        ),
    spendReducer
        .pullback(
            state: \.spendState,
            action: /AppAction.spend,
            environment: { _ in
                SpendEnvironment.live
            }
        )

).combined(with: Reducer<AppState, AppAction, AppEnvironment>({ state, action, _ in
    switch action {
    case .logout:
        state.loginState = LoginState()

        return .none
    case .balance:
        return .none
    case .login:
        state.loginState = nil
        return .none
    case .spend:
        return .none
    case .transaction:
        return .none
    }
}))
