//
//  Outfit.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class Outfit {
    var id: UUID
    var name: String
    var occasionRawValue: String
    var notes: String?
    var isFavorite: Bool
    var dateCreated: Date
    var lastWornDate: Date?
    var wearCount: Int

    var items: [ClothingItem]?

    var occasion: Occasion {
        get { Occasion(rawValue: occasionRawValue) ?? .casual }
        set { occasionRawValue = newValue.rawValue }
    }

    init(
        name: String,
        occasion: Occasion,
        notes: String? = nil,
        items: [ClothingItem] = []
    ) {
        self.id = UUID()
        self.name = name
        self.occasionRawValue = occasion.rawValue
        self.notes = notes
        self.isFavorite = false
        self.dateCreated = Date()
        self.lastWornDate = nil
        self.wearCount = 0
        self.items = items
    }

    func markAsWorn() {
        lastWornDate = Date()
        wearCount += 1
        items?.forEach { $0.markAsWorn() }
    }
}
