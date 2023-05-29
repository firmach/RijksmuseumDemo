//
//  UIColor+HEX.swift
//  RijksmuseumDemo
//
//  Created by Roman Churkin on 29/05/2023.
//

import UIKit


extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        let scanner = Scanner(string: hex)

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = (rgbValue & 0xff)

        self.init(
            red: CGFloat(r) / CGFloat(0xff),
            green: CGFloat(g) / CGFloat(0xff),
            blue: CGFloat(b) / CGFloat(0xff),
            alpha: 1
        )
    }
}
