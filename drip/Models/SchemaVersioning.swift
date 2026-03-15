//
//  SchemaVersioning.swift
//  drip
//

import Foundation
import SwiftData

enum DripSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            ClothingItem.self,
            Outfit.self,
            OutfitLog.self,
            Brand.self,
            WardrobeColor.self,
            Occasion.self,
        ]
    }
}

enum DripMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DripSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
