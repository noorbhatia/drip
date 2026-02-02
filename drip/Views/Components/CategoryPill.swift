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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : .primary)
            
            
        }
        .buttonStyle(.bordered)
        .background(isSelected ? Color.accentColor : Color.clear)
        .clipShape(.capsule)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityLabel("Filter by \(category.displayName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct AllCategoryPill: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("All")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                
                
        }
        .buttonStyle(.bordered)
        .background(isSelected ? Color.accentColor : Color.clear)
        .clipShape(.capsule)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityLabel("Show all items")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
