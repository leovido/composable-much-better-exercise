//
//  LoginView.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
    public let store: Store<LoginState, LoginAction>

    public init(store: Store<LoginState, LoginAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                TextField("Email", text: viewStore.binding(
                    get: { $0.email },
                    send: LoginAction.login
                ),
                prompt: Text("user@muchbetter.com"))
                SecureField("Password", text: viewStore.binding(
                    get: { $0.email },
                    send: LoginAction.login
                ),
                prompt: Text("......"))

                Button(action: {
                    viewStore.send(.login)
                }, label: {
                    Text("Login")
                })
            }
            .onAppear {
                viewStore.send(.login)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static let store: Store<LoginState, LoginAction> = .init(
        initialState: .init(),
        reducer: loginReducer,
        environment: LoginEnvironment.mock
    )

    static var previews: some View {
        LoginView(store: store)
    }
}
