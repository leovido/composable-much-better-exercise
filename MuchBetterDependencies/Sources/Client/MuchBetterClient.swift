//
//  File.swift
//
//
//  Created by Christian Leovido on 12/10/2021.
//

import Combine
import Foundation

public typealias Token = String

public struct TokenResponse: Decodable {
  public var token: Token
}

public enum Constants {
  public static let scheme = "https"
  public static let host = "interviewer-api.herokuapp.com"
}

public enum Method: String {
  case POST
  case GET
}

public final class Client {
  public static let shared = Client()

  private init() {}

  public private(set) var subscriptions: Set<AnyCancellable> = []
  private let token: CurrentValueSubject<Token, Never> = .init("")

  private func makeComponents() -> URLComponents {
    var components = URLComponents()
    components.scheme = Constants.scheme
    components.host = Constants.host

    return components
  }

  public func login(email _: String = "", password _: String = "") -> AnyPublisher<Token, Error> {
    let components = makeComponents()

    guard var url = components.url
    else {
      fatalError()
    }

    url.appendPathComponent(Endpoint.login.rawValue)

    var request = URLRequest(url: url)
    request.httpMethod = Method.POST.rawValue

    //		When using an API that requires an email and a password.
    // 		In this case, there's no need for an email and password to aunthenticate, as the current API doesn't require it
    //		request.httpBody = ...

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let pub = URLSession.shared.dataTaskPublisher(for: request)
      .receive(on: DispatchQueue.main)
      .tryMap {
        guard let res = $0.response as? HTTPURLResponse
        else {
          throw NSError(domain: "Invalid response", code: 404, userInfo: nil) as Error
        }

        guard (200 ..< 399) ~= res.statusCode
        else {
          throw NSError(domain: "Invalid response", code: res.statusCode, userInfo: nil) as Error
        }

        return $0.data
      }
      .decode(type: TokenResponse.self, decoder: JSONDecoder())
      .mapError { $0 }
      .map(\.token)
      .share()

    pub
      .catch { _ -> Just<Token> in
        Just("")
      }
      .subscribe(token)
      .store(in: &subscriptions)

    return pub
      .eraseToAnyPublisher()
  }

  public func makeRequest(data: Data? = nil, endpoint: Endpoint, httpMethod: Method) -> URLRequest? {
    let components = makeComponents()

    guard var url = components.url
    else {
      return nil
    }

    url.appendPathComponent(endpoint.rawValue)

    var request = URLRequest(url: url)
    request.httpBody = data
    request.httpMethod = httpMethod.rawValue

    request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    return request
  }
}

public enum Endpoint: String {
  case login
  case balance
  case transactions
  case spend
}
