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
                Spacer()
                VStack {
                    Text("MuchBetter app".uppercased())
                        .font(.largeTitle)
                        .fontWeight(.black)

                    Text("with TCA (The Composable Architecture)")
                        .font(.caption)
                }
                .padding(.bottom, 50)

                TextField("Email", text: viewStore.binding(
                    get: { $0.email },
                    send: LoginAction.login
                ),
                prompt: Text("user@muchbetter.com"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color.white)
                    .padding([.leading, .trailing])
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: viewStore.binding(
                    get: { $0.email },
                    send: LoginAction.login
                ),
                prompt: Text("········"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])

                Button(action: {
                    viewStore.send(.login)
                }, label: {
                    Text("Login")
                        .foregroundColor(Color.white)
                })
                    .padding(10)
                    .padding([.leading, .trailing], 15)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .padding()

                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
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
