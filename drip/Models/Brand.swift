//
//  Brand.swift
//  drip
//

import SwiftData

@Model
final class Brand {
    @Attribute(.unique) var name: String
    var icon: String

    var clothingItems: [ClothingItem]?

    init(name: String, icon: String) {
        self.name = name
        self.icon = icon
    }

    static let defaults: [(name: String, icon: String)] = [
        ("Nike", "figure.run"),
        ("Adidas", "figure.walk"),
        ("Zara", "tshirt"),
        ("H&M", "hanger"),
        ("Uniqlo", "tshirt.fill"),
        ("Gucci", "sparkles"),
        ("Prada", "handbag"),
        ("Louis Vuitton", "bag"),
        ("Levi's", "tag"),
        ("Gap", "tshirt"),
        ("Ralph Lauren", "figure.equestrian.sport"),
        ("Calvin Klein", "tag.fill"),
        ("Tommy Hilfiger", "flag"),
        ("Burberry", "checkmark.seal"),
        ("Versace", "crown"),
        ("Balenciaga", "shoeprints.fill"),
        ("Dior", "star"),
        ("Chanel", "star.fill"),
        ("Hermès", "gift"),
        ("The North Face", "mountain.2"),
        ("Patagonia", "leaf"),
        ("Lululemon", "figure.yoga"),
        ("Coach", "handbag.fill"),
        ("Michael Kors", "bag.fill"),
        ("New Balance", "shoe")
    ]
}
