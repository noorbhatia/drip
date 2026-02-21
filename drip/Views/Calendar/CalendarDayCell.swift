//
//  CalendarDayCell.swift
//  drip
//

import SwiftUI

struct CalendarDayCell: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasPlanned: Bool
    let hasWorn: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(day)")
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(foregroundColor)
                .frame(width: 32, height: 32)
                .background {
                    if isSelected {
                        Circle()
                            .fill(.accent)
                    } else if isToday {
                        Circle()
                            .strokeBorder(.accent, lineWidth: 1.5)
                    }
                }

            HStack(spacing: 3) {
                if hasPlanned {
                    Circle()
                        .fill(.accent)
                        .frame(width: 5, height: 5)
                }
                if hasWorn {
                    Circle()
                        .fill(.green)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Rectangle())
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if !isCurrentMonth {
            return .secondary.opacity(0.4)
        } else {
            return .primary
        }
    }
}

#Preview {
    HStack {
        CalendarDayCell(day: 1, isToday: true, isSelected: false, isCurrentMonth: true, hasPlanned: false, hasWorn: false)
        CalendarDayCell(day: 15, isToday: false, isSelected: true, isCurrentMonth: true, hasPlanned: true, hasWorn: false)
        CalendarDayCell(day: 28, isToday: false, isSelected: false, isCurrentMonth: true, hasPlanned: true, hasWorn: true)
        CalendarDayCell(day: 3, isToday: false, isSelected: false, isCurrentMonth: false, hasPlanned: false, hasWorn: false)
    }
    .padding()
}
