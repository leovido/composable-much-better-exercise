//
//  File.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

import Foundation

public enum SpendError: Error {
    case message(String)
}

extension SpendError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        }
    }
}
