//
//  File.swift
//
//
//  Created by Christian Leovido on 25/10/2021.
//

import Foundation

public extension JSONEncoder {
  static let customEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    return encoder
  }()
}
