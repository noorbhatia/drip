//
//  Occasion.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class Occasion {
    #Index<Occasion>([\.name], [\.sortOrder])

    @Attribute(.unique) var name: String
    var displayName: String
    var systemImage: String
    var suggestionDescription: String
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Outfit.occasion)
    var outfits: [Outfit]?

    init(name: String, displayName: String, systemImage: String, suggestionDescription: String, sortOrder: Int) {
        self.name = name
        self.displayName = displayName
        self.systemImage = systemImage
        self.suggestionDescription = suggestionDescription
        self.sortOrder = sortOrder
    }

    enum Names {
        static let casual = "casual"
        static let work = "work"
        static let formal = "formal"
        static let date = "date"
        static let athletic = "athletic"
        static let lounge = "lounge"
        static let outdoor = "outdoor"
        static let travel = "travel"
        static let special = "special"
    }

    static let defaults: [(name: String, displayName: String, systemImage: String, suggestionDescription: String, sortOrder: Int)] = [
        (Names.casual, "Casual", "sun.max", "Relaxed and comfortable for everyday", 0),
        (Names.work, "Work", "briefcase", "Professional and polished", 1),
        (Names.formal, "Formal", "star", "Elegant for special occasions", 2),
        (Names.date, "Date Night", "heart", "Stylish and charming", 3),
        (Names.athletic, "Athletic", "figure.run", "Ready for your workout", 4),
        (Names.lounge, "Lounge", "house", "Cozy and comfortable at home", 5),
        (Names.outdoor, "Outdoor", "leaf", "Perfect for adventures", 6),
        (Names.travel, "Travel", "airplane", "Practical and stylish on the go", 7),
        (Names.special, "Special", "sparkles", "Stand out from the crowd", 8),
    ]
}
