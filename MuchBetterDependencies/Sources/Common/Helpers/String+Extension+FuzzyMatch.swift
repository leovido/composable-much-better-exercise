//
//  File.swift
//
//
//  Created by Christian Leovido on 25/10/2021.
//

import Foundation

public extension String {
  func fuzzyMatch(_ string: String) -> Bool {
    let lowercased = string.lowercased()

    let words = map { $0.lowercased() }
      .joined()
      .components(separatedBy: " ")

    for word in words {
      if word == lowercased || word.contains(lowercased) {
        return true
      } else {
        continue
      }
    }

    return false
  }
}
