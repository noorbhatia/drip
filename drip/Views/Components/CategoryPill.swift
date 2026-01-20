//
//  CategoryPill.swift
//  drip
//

import SwiftUI

struct CategoryPill: View {
    let category: ClothingCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.systemImage)
                    .font(.subheadline)
                Text(category.displayName)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(isSelected ? Color.accentColor : Color.clear)
            .clipShape(Capsule())
        }
        .glassEffect(
            isSelected ? .regular.tint(.accentColor).interactive() : .regular.interactive(),
            in: .capsule
        )
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct AllCategoryPill: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("All")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(isSelected ? Color.accentColor : Color.clear)
                .clipShape(Capsule())
        }
        .glassEffect(
            isSelected ? .regular.tint(.accentColor).interactive() : .regular.interactive(),
            in: .capsule
        )
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    HStack {
        AllCategoryPill(isSelected: true, action: {})
        CategoryPill(category: .tops, isSelected: false, action: {})
        CategoryPill(category: .bottoms, isSelected: false, action: {})
    }
    .padding()
}
