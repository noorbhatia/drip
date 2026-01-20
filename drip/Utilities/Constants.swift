//
//  Constants.swift
//  drip
//

import SwiftUI

enum Constants {
    enum Layout {
        static let gridItemMinWidth: CGFloat = 150
        static let gridItemMaxWidth: CGFloat = 180
        static let gridSpacing: CGFloat = 16
        static let cardCornerRadius: CGFloat = 16
        static let fabSize: CGFloat = 56
        static let fabBottomPadding: CGFloat = 20
    }

    enum Animation {
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.7
        static let snappyDuration: Double = 0.25
    }

    enum Strings {
        static let appName = "Drip"
        static let homeTab = "Home"
        static let closetTab = "Closet"
        static let addClothes = "Add Clothes"
        static let buildOutfit = "Build Outfit"
        static let emptyClosetTitle = "Your closet is empty"
        static let emptyClosetMessage = "Start by adding your first clothing item"
        static let emptyOutfitsTitle = "No outfits yet"
        static let emptyOutfitsMessage = "Create your first outfit from your wardrobe"
    }

    static func timeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Good night"
        }
    }
}
