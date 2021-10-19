//
//  File.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

import Foundation

public enum LoginError: Error, Hashable {
    case message(String)
}

extension LoginError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        }
    }
}
