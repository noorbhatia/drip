//
//  ClothingImportActor.swift
//  drip
//

import SwiftData
import SwiftUI

@ModelActor
actor ClothingImportActor {
    /// Import multiple images as ClothingItems with default values
    /// Runs entirely on background thread
    func importClothingItems(from imageDataArray: [Data]) throws {
        for imageData in imageDataArray {
            let item = ClothingItem(
                name: "New Item",
                imageData: imageData,
                category: .tops,
                color: .black,
                tags: []
            )
            modelContext.insert(item)
        }
        try modelContext.save()
    }
}
