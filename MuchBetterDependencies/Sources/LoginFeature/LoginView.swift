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
                    send: LoginAction.emailValidate
                ),
                prompt: Text("user@muchbetter.com"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .border(viewStore.isEmailValid == nil ? Color.clear : (viewStore.isEmailValid! ? Color.green : Color.red), width: 1)
                    .background(Color.white)
                    .padding([.leading, .trailing])
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: viewStore.binding(
                    get: { $0.email },
                    send: LoginAction.passwordValidate
                ),
                prompt: Text("········"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .border(viewStore.isPasswordValid == nil ? Color.clear : (viewStore.isPasswordValid! ? Color.green : Color.red), width: 1)
                    .padding([.leading, .trailing])

                Button(action: {
                    withAnimation {
                        viewStore.send(.login)
                    }
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
