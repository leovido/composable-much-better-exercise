//
//  File.swift
//
//
//  Created by Christian Leovido on 17/10/2021.
//

import Foundation

public enum MuchBetterNumberFormatter {
    public static func formatCurrency(_ model: AmountRepresentable) -> String {
        let nf = NumberFormatter()

        nf.locale = Locale.current
        nf.usesGroupingSeparator = true
        nf.currencySymbol = model.currency.description
        nf.numberStyle = .currency

        guard let number = Float(model.amount) else {
            return ""
        }

        return nf.string(from: NSNumber(value: number)) ?? ""
    }

    public static func number(from string: String) -> Float {
        let nf = NumberFormatter()

        nf.locale = Locale.current
        nf.usesGroupingSeparator = true
        nf.currencySymbol = "£"
        nf.numberStyle = .currency

        guard let number = nf.number(from: string) else {
            return 0
        }

        return Float(truncating: number)
    }
}
