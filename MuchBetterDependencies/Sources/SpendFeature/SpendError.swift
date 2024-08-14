import Foundation

public enum SpendError: Error, Hashable {
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
