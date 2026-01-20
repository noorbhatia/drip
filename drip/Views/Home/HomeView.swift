//
//  HomeView.swift
//  drip
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var clothingItems: [ClothingItem]
    @Query(sort: \Outfit.dateCreated, order: .reverse) private var outfits: [Outfit]

    @State private var suggestionService = OutfitSuggestionService()
    @State private var showOutfitBuilder = false
    @State private var selectedOccasion: Occasion?

    private var recentOutfits: [Outfit] {
        Array(outfits.prefix(5))
    }

    private var favoriteItemsCount: Int {
        clothingItems.filter { $0.isFavorite }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    greetingSection
                    outfitIdeasSection
                    RecentOutfitsSection(outfits: recentOutfits)
                    statsSection
                }
                .padding(.vertical)
                .padding(.bottom, 100)
            }
            .navigationTitle(Constants.Strings.homeTab)
            .toolbarTitleDisplayMode(.inlineLarge)
//            .navigationSubtitle("Hi")
            .fullScreenCover(isPresented: $showOutfitBuilder) {
                OutfitBuilderView(preselectedOccasion: selectedOccasion)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accent)
                }
            }
        }
    }

    private var greetingSection: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Constants.timeBasedGreeting())
                        .font(.title2.weight(.semibold))

                    Text("What will you wear today?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: greetingIcon)
                    .font(.largeTitle)
                    .foregroundStyle(.accent)
            }
            .padding()
        
    }

    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sun.max.fill"
        case 12..<17: return "sun.min.fill"
        case 17..<22: return "moon.fill"
        default: return "moon.stars.fill"
        }
    }

    private var outfitIdeasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("Outfit Ideas")
                    .font(.title3.weight(.semibold))
                    .padding(.leading)
                Image(systemName: "chevron.right")
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestionService.getSuggestions()) { suggestion in
                        OutfitSuggestionCard(
                            occasion: suggestion.occasion,
                            description: suggestion.description,
                            onTap: {
                                selectedOccasion = suggestion.occasion
                                showOutfitBuilder = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wardrobe Stats")
                .font(.title3.weight(.semibold))
                .padding(.horizontal)

            GlassCard {
                HStack(spacing: 0) {
                    statItem(
                        value: "\(clothingItems.count)",
                        label: "Items",
                        icon: "tshirt"
                    )

                    Divider()
                        .frame(height: 50)

                    statItem(
                        value: "\(outfits.count)",
                        label: "Outfits",
                        icon: "rectangle.stack"
                    )

                    Divider()
                        .frame(height: 50)

                    statItem(
                        value: "\(favoriteItemsCount)",
                        label: "Favorites",
                        icon: "heart.fill"
                    )
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal)
        }
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accent)

            Text(value)
                .font(.title.weight(.bold))

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewData.previewContainer)
}
