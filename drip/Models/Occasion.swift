//
//  Occasion.swift
//  drip
//

import Foundation

enum Occasion: String, Codable, CaseIterable, Identifiable {
    case casual
    case work
    case formal
    case date
    case athletic
    case lounge
    case outdoor
    case travel
    case special

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .casual: return "Casual"
        case .work: return "Work"
        case .formal: return "Formal"
        case .date: return "Date Night"
        case .athletic: return "Athletic"
        case .lounge: return "Lounge"
        case .outdoor: return "Outdoor"
        case .travel: return "Travel"
        case .special: return "Special"
        }
    }

    var systemImage: String {
        switch self {
        case .casual: return "sun.max"
        case .work: return "briefcase"
        case .formal: return "star"
        case .date: return "heart"
        case .athletic: return "figure.run"
        case .lounge: return "house"
        case .outdoor: return "leaf"
        case .travel: return "airplane"
        case .special: return "sparkles"
        }
    }
}
