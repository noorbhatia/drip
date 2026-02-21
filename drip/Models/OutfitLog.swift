//
//  OutfitLog.swift
//  drip
//

import Foundation
import SwiftData

@Model
final class OutfitLog {
    var id: UUID
    var date: Date
    var typeRawValue: String
    var createdAt: Date
    var outfit: Outfit?

    enum LogType: String {
        case planned
        case worn
    }

    var type: LogType {
        get { LogType(rawValue: typeRawValue) ?? .planned }
        set { typeRawValue = newValue.rawValue }
    }

    init(type: LogType, date: Date, outfit: Outfit? = nil) {
        self.id = UUID()
        self.date = date
        self.typeRawValue = type.rawValue
        self.createdAt = Date()
        self.outfit = outfit
    }
}
