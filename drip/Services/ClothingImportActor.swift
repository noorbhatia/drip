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
    func importClothingItems(from imageDataArray: [Data], defaultColorID: PersistentIdentifier?) throws {
        let defaultColor: WardrobeColor?
        if let colorID = defaultColorID {
            defaultColor = modelContext.model(for: colorID) as? WardrobeColor
        } else {
            defaultColor = nil
        }

        for imageData in imageDataArray {
            let item = ClothingItem(
                name: "New Item",
                imageData: imageData,
                category: .tops,
                wardrobeColor: defaultColor,
                tags: []
            )
            modelContext.insert(item)
        }
        try modelContext.save()
    }
}
