//
//  WardrobeColor.swift
//  drip
//

import SwiftUI

enum WardrobeColor: String, Codable, CaseIterable, Identifiable {
    case black
    case white
    case gray
    case navy
    case blue
    case lightBlue
    case red
    case pink
    case orange
    case yellow
    case green
    case olive
    case purple
    case brown
    case beige
    case cream
    case multicolor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .black: return "Black"
        case .white: return "White"
        case .gray: return "Gray"
        case .navy: return "Navy"
        case .blue: return "Blue"
        case .lightBlue: return "Light Blue"
        case .red: return "Red"
        case .pink: return "Pink"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .olive: return "Olive"
        case .purple: return "Purple"
        case .brown: return "Brown"
        case .beige: return "Beige"
        case .cream: return "Cream"
        case .multicolor: return "Multicolor"
        }
    }

    var color: Color {
        switch self {
        case .black: return .black
        case .white: return .white
        case .gray: return .gray
        case .navy: return Color(red: 0, green: 0, blue: 0.5)
        case .blue: return .blue
        case .lightBlue: return Color(red: 0.68, green: 0.85, blue: 0.9)
        case .red: return .red
        case .pink: return .pink
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .olive: return Color(red: 0.5, green: 0.5, blue: 0)
        case .purple: return .purple
        case .brown: return .brown
        case .beige: return Color(red: 0.96, green: 0.96, blue: 0.86)
        case .cream: return Color(red: 1, green: 0.99, blue: 0.82)
        case .multicolor: return .clear
        }
    }
}
