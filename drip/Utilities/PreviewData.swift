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
            tags: ["casual", "basic"],
            brand: Brand(name: "Uniqlo", icon: "tshirt.fill")
        ),
        ClothingItem(
            name: "Blue Jeans",
            category: .bottoms,
            tags: ["casual", "denim"],
            brand: Brand(name: "Levi's", icon: "tag")
        ),
        ClothingItem(
            name: "Black Blazer",
            category: .outerwear,
            tags: ["formal", "work"],
            brand: Brand(name: "Zara", icon: "tshirt")
        ),
        ClothingItem(
            name: "Running Shoes",
            category: .shoes,
            tags: ["athletic", "running"],
            brand: Brand(name: "Nike", icon: "figure.run")
        ),
        ClothingItem(
            name: "Summer Dress",
            category: .dresses,
            tags: ["summer", "casual"],
            brand: Brand(name: "H&M", icon: "hanger")
        ),
        ClothingItem(
            name: "Leather Bag",
            category: .bags,
            tags: ["everyday"],
            brand: Brand(name: "Coach", icon: "handbag.fill")
        )
    ]

    static var previewContainer: ModelContainer {
        let schema = Schema([
            ClothingItem.self,
            Outfit.self,
            OutfitLog.self,
            Brand.self,
            WardrobeColor.self,
            Occasion.self,
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext

            // Seed default colors
            for def in WardrobeColor.defaults {
                context.insert(WardrobeColor(
                    name: def.name,
                    displayName: def.displayName,
                    hexValue: def.hexValue,
                    sortOrder: def.sortOrder
                ))
            }

            // Seed default occasions
            for def in Occasion.defaults {
                context.insert(Occasion(
                    name: def.name,
                    displayName: def.displayName,
                    systemImage: def.systemImage,
                    suggestionDescription: def.suggestionDescription,
                    sortOrder: def.sortOrder
                ))
            }

            try context.save()

            // Fetch inserted colors/occasions for sample data
            let colors = try context.fetch(FetchDescriptor<WardrobeColor>(sortBy: [SortDescriptor(\.sortOrder)]))
            let occasions = try context.fetch(FetchDescriptor<Occasion>(sortBy: [SortDescriptor(\.sortOrder)]))

            let whiteColor = colors.first { $0.name == WardrobeColor.Names.white }
            let blueColor = colors.first { $0.name == WardrobeColor.Names.blue }
            let blackColor = colors.first { $0.name == WardrobeColor.Names.black }
            let grayColor = colors.first { $0.name == WardrobeColor.Names.gray }
            let pinkColor = colors.first { $0.name == WardrobeColor.Names.pink }
            let brownColor = colors.first { $0.name == WardrobeColor.Names.brown }
            let casualOccasion = occasions.first { $0.name == Occasion.Names.casual }

            let items = sampleClothingItems
            let colorMap: [String: WardrobeColor?] = [
                "White T-Shirt": whiteColor,
                "Blue Jeans": blueColor,
                "Black Blazer": blackColor,
                "Running Shoes": grayColor,
                "Summer Dress": pinkColor,
                "Leather Bag": brownColor,
            ]

            for item in items {
                item.wardrobeColor = colorMap[item.name] ?? blackColor
                context.insert(item)
            }

            let sampleOutfit = Outfit(
                name: "Casual Friday",
                occasion: casualOccasion,
                notes: "Perfect for casual occasions"
            )
            context.insert(sampleOutfit)

            try context.save()

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
