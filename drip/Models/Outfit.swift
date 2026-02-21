//
//  Outfit.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class Outfit: Identifiable {
    var id: UUID
    var name: String
    var occasionRawValue: String
    var notes: String?
    var isFavorite: Bool
    var dateCreated: Date

    @Attribute(.externalStorage) var previewImageData: Data?

    var items: [ClothingItem]?

    @Relationship(deleteRule: .cascade, inverse: \OutfitLog.outfit)
    var logs: [OutfitLog]?

    var occasion: Occasion {
        get { Occasion(rawValue: occasionRawValue) ?? .casual }
        set { occasionRawValue = newValue.rawValue }
    }

    var lastWornDate: Date? {
        logs?.filter { $0.type == .worn }
            .max(by: { $0.date < $1.date })?.date
    }

    var wearCount: Int {
        logs?.filter { $0.type == .worn }.count ?? 0
    }

    var plannedDates: [Date] {
        logs?.filter { $0.type == .planned }.map(\.date) ?? []
    }

    var wornDates: [Date] {
        logs?.filter { $0.type == .worn }.map(\.date) ?? []
    }

    init(
        name: String,
        occasion: Occasion,
        notes: String? = nil,
        items: [ClothingItem] = [],
        previewImageData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.occasionRawValue = occasion.rawValue
        self.notes = notes
        self.isFavorite = false
        self.dateCreated = Date()
        self.previewImageData = previewImageData
        self.items = items
    }
}
