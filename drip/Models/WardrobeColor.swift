//
//  WardrobeColor.swift
//  drip
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class WardrobeColor {
    #Index<WardrobeColor>([\.name], [\.sortOrder])

    @Attribute(.unique) var name: String
    var displayName: String
    var hexValue: String
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \ClothingItem.wardrobeColor)
    var clothingItems: [ClothingItem]?

    var swiftUIColor: Color {
        if hexValue == "#MULTI" { return .clear }
        return Color(hex: hexValue)
    }

    var isMulticolor: Bool {
        name == Names.multicolor
    }

    var isLightColor: Bool {
        name == Names.white || name == Names.cream || name == Names.beige
    }

    init(name: String, displayName: String, hexValue: String, sortOrder: Int) {
        self.name = name
        self.displayName = displayName
        self.hexValue = hexValue
        self.sortOrder = sortOrder
    }

    enum Names {
        static let black = "black"
        static let white = "white"
        static let gray = "gray"
        static let navy = "navy"
        static let blue = "blue"
        static let lightBlue = "lightBlue"
        static let red = "red"
        static let pink = "pink"
        static let orange = "orange"
        static let yellow = "yellow"
        static let green = "green"
        static let olive = "olive"
        static let purple = "purple"
        static let brown = "brown"
        static let beige = "beige"
        static let cream = "cream"
        static let multicolor = "multicolor"
    }

    static let defaults: [(name: String, displayName: String, hexValue: String, sortOrder: Int)] = [
        (Names.black, "Black", "#000000", 0),
        (Names.white, "White", "#FFFFFF", 1),
        (Names.gray, "Gray", "#808080", 2),
        (Names.navy, "Navy", "#000080", 3),
        (Names.blue, "Blue", "#0000FF", 4),
        (Names.lightBlue, "Light Blue", "#ADD8E6", 5),
        (Names.red, "Red", "#FF0000", 6),
        (Names.pink, "Pink", "#FF69B4", 7),
        (Names.orange, "Orange", "#FF8C00", 8),
        (Names.yellow, "Yellow", "#FFD700", 9),
        (Names.green, "Green", "#00AA00", 10),
        (Names.olive, "Olive", "#808000", 11),
        (Names.purple, "Purple", "#800080", 12),
        (Names.brown, "Brown", "#8B4513", 13),
        (Names.beige, "Beige", "#F5F5DC", 14),
        (Names.cream, "Cream", "#FFFFD1", 15),
        (Names.multicolor, "Multicolor", "#MULTI", 16),
    ]
}
