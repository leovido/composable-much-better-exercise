//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Foundation

public enum TransactionError: Error, Hashable {
    case message(String)
}

extension TransactionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        }
    }
}
