//
//  CalendarData.swift
//  drip
//
//  Created by Noor Bhatia on 08/02/26.
//

import SwiftUI

struct Month: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var date: Date
    var weeks: [Week]
}

struct Week: Identifiable {
    var id: String = UUID().uuidString
    var days: [Day]
    var isLast: Bool = false
}

struct Day: Identifiable {
    var id: String = UUID().uuidString
    var value: Int?
    var date: Date?
    var isPlaceholder: Bool
}
