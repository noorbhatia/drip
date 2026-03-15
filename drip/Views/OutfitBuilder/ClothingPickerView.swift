//
//  ClothingPickerView.swift
//  drip
//

import SwiftData
import SwiftUI

struct ClothingPickerView: View {
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var allItems: [ClothingItem]

    @Binding var selectedItems: Set<UUID>
    @State private var selectedCategory: ClothingCategory?
    @State private var searchText = ""

    private var filteredItems: [ClothingItem] {
        var items = allItems

        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            items = items.filter { item in
                item.name.lowercased().contains(lowercasedQuery) ||
                item.brand?.name.lowercased().contains(lowercasedQuery) == true
            }
        }

        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryTabs
                .padding(.vertical, 8)

            if allItems.isEmpty {
                EmptyStateView(
                    title: "No items yet",
                    message: "Add some clothes to your closet first",
                    systemImage: "cabinet"
                )
                .frame(maxHeight: .infinity)
            } else if filteredItems.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScrollView {
                    ClothingGridView(
                        items: filteredItems,
                        selectedItems: selectedItems,
                        onItemTap: { toggleSelection($0) },
                        isSelectionMode: true
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search items")
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                AllCategoryPill(
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                ForEach(ClothingCategory.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private func toggleSelection(_ item: ClothingItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
}

#Preview {
    NavigationStack {
        ClothingPickerView(selectedItems: .constant([]))
    }
    .modelContainer(PreviewData.previewContainer)
}
