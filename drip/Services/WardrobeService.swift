//
//  WardrobeService.swift
//  drip
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class WardrobeService {
    private let modelContext: ModelContext

    var clothingItems: [ClothingItem] = []
    var outfits: [Outfit] = []
    var wardrobeColors: [WardrobeColor] = []
    var occasions: [Occasion] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchAll()
    }

    func fetchAll() {
        fetchClothingItems()
        fetchOutfits()
        fetchWardrobeColors()
        fetchOccasions()
    }

    func fetchClothingItems() {
        let descriptor = FetchDescriptor<ClothingItem>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        do {
            clothingItems = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch clothing items: \(error)")
            clothingItems = []
        }
    }

    func fetchOutfits() {
        let descriptor = FetchDescriptor<Outfit>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        do {
            outfits = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch outfits: \(error)")
            outfits = []
        }
    }

    func fetchWardrobeColors() {
        let descriptor = FetchDescriptor<WardrobeColor>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        do {
            wardrobeColors = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch wardrobe colors: \(error)")
            wardrobeColors = []
        }
    }

    func fetchOccasions() {
        let descriptor = FetchDescriptor<Occasion>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        do {
            occasions = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch occasions: \(error)")
            occasions = []
        }
    }

    func defaultColor() -> WardrobeColor? {
        wardrobeColors.first { $0.name == WardrobeColor.Names.black }
    }

    func defaultOccasion() -> Occasion? {
        occasions.first { $0.name == Occasion.Names.casual }
    }

    func addClothingItem(_ item: ClothingItem) {
        modelContext.insert(item)
        saveContext()
        fetchClothingItems()
    }

    func deleteClothingItem(_ item: ClothingItem) {
        modelContext.delete(item)
        saveContext()
        fetchClothingItems()
    }

    func addOutfit(_ outfit: Outfit) {
        modelContext.insert(outfit)
        saveContext()
        fetchOutfits()
    }

    func deleteOutfit(_ outfit: Outfit) {
        modelContext.delete(outfit)
        saveContext()
        fetchOutfits()
    }

    func clothingItems(for category: ClothingCategory?) -> [ClothingItem] {
        guard let category else { return clothingItems }
        return clothingItems.filter { $0.category == category }
    }

    func searchClothingItems(query: String) -> [ClothingItem] {
        guard !query.isEmpty else { return clothingItems }
        let lowercasedQuery = query.lowercased()
        return clothingItems.filter { item in
            item.name.lowercased().contains(lowercasedQuery) ||
            item.brand?.name.lowercased().contains(lowercasedQuery) == true ||
            item.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }

    func recentOutfits(limit: Int = 5) -> [Outfit] {
        Array(outfits.prefix(limit))
    }

    func favoriteItems() -> [ClothingItem] {
        clothingItems.filter { $0.isFavorite }
    }

    func favoriteOutfits() -> [Outfit] {
        outfits.filter { $0.isFavorite }
    }

    func outfitsPlanned(for date: Date) -> [Outfit] {
        outfits.filter { outfit in
            outfit.logs?.contains { log in
                log.type == .planned && Calendar.current.isDate(log.date, inSameDayAs: date)
            } ?? false
        }
    }

    func outfitsWorn(on date: Date) -> [Outfit] {
        outfits.filter { outfit in
            outfit.logs?.contains { log in
                log.type == .worn && Calendar.current.isDate(log.date, inSameDayAs: date)
            } ?? false
        }
    }

    func planOutfit(_ outfit: Outfit, for date: Date) {
        let log = OutfitLog(type: .planned, date: date, outfit: outfit)
        modelContext.insert(log)
        saveContext()
        fetchOutfits()
    }

    func unplanOutfit(_ outfit: Outfit, for date: Date) {
        let logsToDelete = outfit.logs?.filter { log in
            log.type == .planned && Calendar.current.isDate(log.date, inSameDayAs: date)
        } ?? []
        for log in logsToDelete {
            modelContext.delete(log)
        }
        saveContext()
        fetchOutfits()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
