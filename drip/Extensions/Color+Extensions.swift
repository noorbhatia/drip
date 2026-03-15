//
//  Color+Extensions.swift
//  drip
//
//  Created by Noor Bhatia on 26/01/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func luminance() -> Double {
        // 1. Convert SwiftUI Color to UIColor
        let uiColor = UIColor(self)
        
        // 2. Extract RGB values
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // 3. Compute luminance.
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }
    
    func isLight() -> Bool {
        return luminance() > 0.5
    }
    
    func adaptedTextColor() -> Color {
        return isLight() ? Color.black : Color.white
    }
}

extension UIColor {
    var contrastTextColor: Color {
        // Get the red, green, blue values
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Calculate luminance (perceived brightness)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        // Return white for dark backgrounds, black for light backgrounds
        return luminance < 0.6 ? .white : .black // 0.6 is an accessibility-friendly threshold
    }
}
