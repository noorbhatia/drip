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
        static let cardCornerRadius: CGFloat = 12
        static let hStackItemSpacing: CGFloat = 12
        static let fabSize: CGFloat = 56
        static let fabBottomPadding: CGFloat = 20
        static let heroCardHeight: CGFloat = 350
        static let outfitCollectionItemWidth: CGFloat = 200
        static let outfitCollectionItemHeight: CGFloat = 250
        static let categoryItemSize: CGFloat = 120
        static let recentItemSize: CGFloat = 80
        static let sectionSpacing: CGFloat = 24
    }

    enum Animation {
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.7
        static let snappyDuration: Double = 0.25
    }

    enum Canvas {
        static let minScale: CGFloat = 0.3
        static let maxScale: CGFloat = 2.5
        static let maxItemDimension: CGFloat = 150
        static let selectionBorderWidth: CGFloat = 3
        static let handleSize: CGFloat = 12
        static let backgroundColors: [Color] = [
            .white,
            Color(red: 0.98, green: 0.98, blue: 0.98),
            Color(red: 0.95, green: 0.95, blue: 0.97),
            Color(red: 0.94, green: 0.97, blue: 0.98),
            Color(red: 0.98, green: 0.96, blue: 0.94),
            Color(red: 0.96, green: 0.94, blue: 0.96),
            .black,
            Color(red: 0.15, green: 0.15, blue: 0.18),
        ]
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
