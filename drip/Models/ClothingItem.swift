//
//  ClothingItem.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class ClothingItem {
    var id: UUID
    var name: String
    @Attribute(.externalStorage) var imageData: Data?
    var categoryRawValue: String
    var colorRawValue: String
    var tags: [String]
    var brand: String?
    var notes: String?
    var isFavorite: Bool
    var dateAdded: Date
    var lastWornDate: Date?
    var wearCount: Int

    @Relationship(inverse: \Outfit.items)
    var outfits: [Outfit]?

    var category: ClothingCategory {
        get { ClothingCategory(rawValue: categoryRawValue) ?? .tops }
        set { categoryRawValue = newValue.rawValue }
    }

    var color: WardrobeColor {
        get { WardrobeColor(rawValue: colorRawValue) ?? .black }
        set { colorRawValue = newValue.rawValue }
    }

    init(
        name: String,
        imageData: Data? = nil,
        category: ClothingCategory,
        color: WardrobeColor,
        tags: [String] = [],
        brand: String? = nil,
        notes: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.imageData = imageData
        self.categoryRawValue = category.rawValue
        self.colorRawValue = color.rawValue
        self.tags = tags
        self.brand = brand
        self.notes = notes
        self.isFavorite = isFavorite
        self.dateAdded = Date()
        self.lastWornDate = nil
        self.wearCount = 0
        self.outfits = []
    }

    func markAsWorn() {
        lastWornDate = Date()
        wearCount += 1
    }
}
