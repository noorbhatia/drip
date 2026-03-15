//
//  Outfit.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class Outfit: Identifiable {
    #Index<Outfit>([\.dateCreated])

    var id: UUID
    var name: String
    var notes: String?
    var isFavorite: Bool
    var dateCreated: Date

    @Attribute(.externalStorage) var previewImageData: Data?

    var occasion: Occasion?

    @Relationship(deleteRule: .nullify)
    var items: [ClothingItem]?

    @Relationship(deleteRule: .cascade, inverse: \OutfitLog.outfit)
    var logs: [OutfitLog]?

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
    
    var price: Decimal? {
        items?.compactMap(\.price).reduce(0, +) ?? 0
    }
    
    init(
        name: String,
        occasion: Occasion? = nil,
        notes: String? = nil,
        items: [ClothingItem] = [],
        previewImageData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.occasion = occasion
        self.notes = notes
        self.isFavorite = false
        self.dateCreated = Date()
        self.previewImageData = previewImageData
        self.items = items
    }
}
