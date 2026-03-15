//
//  ClothingItem.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class ClothingItem {
    #Index<ClothingItem>([\.dateAdded], [\.categoryRawValue], [\.isFavorite])

    var id: UUID
    var name: String
    @Attribute(.externalStorage) var imageData: Data?
    var categoryRawValue: String
    var tags: [String]
    @Relationship(deleteRule: .nullify, inverse: \Brand.clothingItems)
    var brand: Brand?
    var notes: String?
    var isFavorite: Bool
    var dateAdded: Date

    var wardrobeColor: WardrobeColor?
    var price: Decimal?
    @Relationship(deleteRule: .nullify, inverse: \Outfit.items)
    var outfits: [Outfit]?

    var category: ClothingCategory {
        get { ClothingCategory(rawValue: categoryRawValue) ?? .tops }
        set { categoryRawValue = newValue.rawValue }
    }

    var wearCount: Int {
        let allLogs = outfits?.flatMap { $0.logs ?? [] } ?? []
        return allLogs.filter { $0.type == .worn }.count
    }

    var lastWornDate: Date? {
        let allLogs = outfits?.flatMap { $0.logs ?? [] } ?? []
        return allLogs.filter { $0.type == .worn }
            .max(by: { $0.date < $1.date })?.date
    }

    init(
        name: String,
        imageData: Data? = nil,
        category: ClothingCategory,
        wardrobeColor: WardrobeColor? = nil,
        tags: [String] = [],
        brand: Brand? = nil,
        notes: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.imageData = imageData
        self.categoryRawValue = category.rawValue
        self.wardrobeColor = wardrobeColor
        self.tags = tags
        self.brand = brand
        self.notes = notes
        self.isFavorite = isFavorite
        self.dateAdded = Date()
        self.outfits = []
    }
}
