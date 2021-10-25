//
//  File.swift
//
//
//  Created by Christian Leovido on 25/10/2021.
//

import Client
import ComposableArchitecture
import Foundation

public extension LoginEnvironment {
    static let live: LoginEnvironment = .init { _, _ in
        Client.shared.login()
            .mapError { LoginError.message($0.localizedDescription) }
            .eraseToEffect()
    }
}
