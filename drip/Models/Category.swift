//
//  Category.swift
//  drip
//

import Foundation

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case tops
    case bottoms
    case dresses
    case outerwear
    case shoes
    case accessories
    case bags
    case activewear
    case swimwear
    case formal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tops: return "Tops"
        case .bottoms: return "Bottoms"
        case .dresses: return "Dresses"
        case .outerwear: return "Outerwear"
        case .shoes: return "Shoes"
        case .accessories: return "Accessories"
        case .bags: return "Bags"
        case .activewear: return "Activewear"
        case .swimwear: return "Swimwear"
        case .formal: return "Formal"
        }
    }

    var systemImage: String {
        switch self {
        case .tops: return "tshirt"
        case .bottoms: return "figure.walk"
        case .dresses: return "figure.stand.dress"
        case .outerwear: return "cloud.snow"
        case .shoes: return "shoe"
        case .accessories: return "sparkles"
        case .bags: return "bag"
        case .activewear: return "figure.run"
        case .swimwear: return "drop"
        case .formal: return "star"
        }
    }
}
