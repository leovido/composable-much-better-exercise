//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Foundation

public enum MuchBetterNumberFormatter {
  public static func formatCurrency(_ model: AmountRepresentable) -> String {
    let numberFormatter = NumberFormatter()

    numberFormatter.locale = Locale.current
    numberFormatter.usesGroupingSeparator = true
    numberFormatter.currencySymbol = model.currency.description
    numberFormatter.numberStyle = .currency

    guard let number = Float(model.amount)
    else {
      return ""
    }

    return numberFormatter.string(from: NSNumber(value: number)) ?? ""
  }

  public static func number(from string: String) -> Float {
    let numberFormatter = NumberFormatter()

    numberFormatter.locale = Locale.current
    numberFormatter.usesGroupingSeparator = true
    numberFormatter.currencySymbol = "£"
    numberFormatter.numberStyle = .currency

    guard let number = numberFormatter.number(from: string)
    else {
      return 0
    }

    return Float(truncating: number)
  }
}
