//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Foundation

public enum BalanceError: Error, Hashable {
    case message(String)
}

extension BalanceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        }
    }
}
