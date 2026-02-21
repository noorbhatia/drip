//
//  PreviewData.swift
//  drip
//

import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static let sampleClothingItems: [ClothingItem] = [
        ClothingItem(
            name: "White T-Shirt",
            category: .tops,
            color: .white,
            tags: ["casual", "basic"],
            brand: "Uniqlo"
        ),
        ClothingItem(
            name: "Blue Jeans",
            category: .bottoms,
            color: .blue,
            tags: ["casual", "denim"],
            brand: "Levi's"
        ),
        ClothingItem(
            name: "Black Blazer",
            category: .outerwear,
            color: .black,
            tags: ["formal", "work"],
            brand: "Zara"
        ),
        ClothingItem(
            name: "Running Shoes",
            category: .shoes,
            color: .gray,
            tags: ["athletic", "running"],
            brand: "Nike"
        ),
        ClothingItem(
            name: "Summer Dress",
            category: .dresses,
            color: .pink,
            tags: ["summer", "casual"],
            brand: "H&M"
        ),
        ClothingItem(
            name: "Leather Bag",
            category: .bags,
            color: .brown,
            tags: ["everyday"],
            brand: "Coach"
        )
    ]

    static var previewContainer: ModelContainer {
        let schema = Schema([ClothingItem.self, Outfit.self, OutfitLog.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext

            for item in sampleClothingItems {
                context.insert(item)
            }

            let sampleOutfit = Outfit(
                name: "Casual Friday",
                occasion: .casual,
                notes: "Perfect for casual occasions"
            )
            context.insert(sampleOutfit)

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
