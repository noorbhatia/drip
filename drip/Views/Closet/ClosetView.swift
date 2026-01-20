//
//  ClosetView.swift
//  drip
//

import SwiftData
import SwiftUI

struct ClosetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var allItems: [ClothingItem]

    @State private var searchText = ""
    @State private var selectedCategory: ClothingCategory?
    @State private var showAddClothing = false

    private var filteredItems: [ClothingItem] {
        var items = allItems

        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            items = items.filter { item in
                item.name.lowercased().contains(lowercasedQuery) ||
                item.brand?.lowercased().contains(lowercasedQuery) == true ||
                item.tags.contains { $0.lowercased().contains(lowercasedQuery) }
            }
        }

        return items
    }

    var body: some View {
        NavigationStack {
            Group {
                if allItems.isEmpty {
                    EmptyStateView(
                        title: Constants.Strings.emptyClosetTitle,
                        message: Constants.Strings.emptyClosetMessage,
                        systemImage: "cabinet",
                        action: { showAddClothing = true },
                        actionTitle: "Add First Item"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ClosetFilterView(selectedCategory: $selectedCategory)
                                .padding(.top, 8)

                            if filteredItems.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                                    .padding(.top, 60)
                            } else {
                                ClothingGridView(items: filteredItems)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(Constants.Strings.closetTab)
            .searchable(text: $searchText, prompt: "Search your closet")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddClothing = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddClothing) {
                AddClothingView()
            }
        }
    }
}

#Preview {
    ClosetView()
        .modelContainer(PreviewData.previewContainer)
}
