//
//  ClothingGridView.swift
//  drip
//

import SwiftUI

struct ClothingGridView: View {
    let items: [ClothingItem]
    var selectedItems: Set<UUID> = []
    var onItemTap: ((ClothingItem) -> Void)?
    var isSelectionMode: Bool = false

    private let columns = [
        GridItem(.adaptive(minimum: Constants.Layout.gridItemMinWidth, maximum: Constants.Layout.gridItemMaxWidth), spacing: Constants.Layout.gridSpacing)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Constants.Layout.gridSpacing) {
            ForEach(items) { item in
                if isSelectionMode {
                    ClothingItemCard(
                        item: item,
                        isSelected: selectedItems.contains(item.id)
                    )
                    .onTapGesture {
                        onItemTap?(item)
                    }
                } else {
                    NavigationLink {
                        ClothingDetailView(item: item)
                    } label: {
                        ClothingItemCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ClothingGridView(items: PreviewData.sampleClothingItems)
        }
    }
}
