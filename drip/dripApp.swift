//
//  dripApp.swift
//  drip
//
//  Created by Noor Bhatia on 17/01/26.
//

import SwiftData
import SwiftUI

@main
struct dripApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ClothingItem.self,
            Outfit.self,
            OutfitLog.self,
            Brand.self,
            WardrobeColor.self,
            Occasion.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: DripMigrationPlan.self,
                configurations: [modelConfiguration]
            )
            seedDefaultsIfNeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }

    @MainActor
    private static func seedDefaultsIfNeeded(in context: ModelContext) {
        let colorCount = (try? context.fetchCount(FetchDescriptor<WardrobeColor>())) ?? 0
        if colorCount == 0 {
            for def in WardrobeColor.defaults {
                context.insert(WardrobeColor(
                    name: def.name,
                    displayName: def.displayName,
                    hexValue: def.hexValue,
                    sortOrder: def.sortOrder
                ))
            }
        }

        let occasionCount = (try? context.fetchCount(FetchDescriptor<Occasion>())) ?? 0
        if occasionCount == 0 {
            for def in Occasion.defaults {
                context.insert(Occasion(
                    name: def.name,
                    displayName: def.displayName,
                    systemImage: def.systemImage,
                    suggestionDescription: def.suggestionDescription,
                    sortOrder: def.sortOrder
                ))
            }
        }

        try? context.save()
    }
}
