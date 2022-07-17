//
//  File.swift
//
//
//  Created by Christian Leovido on 18/10/2021.
//

import Foundation

public var transactionDecoder: JSONDecoder {
  let dec = JSONDecoder()
  dec.dateDecodingStrategy = .iso8601

  return dec
}
