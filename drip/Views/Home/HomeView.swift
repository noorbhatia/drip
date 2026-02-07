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
    @State private var woreOutfitID: UUID?

    // MARK: - Derived Data

    private var recentItems: [ClothingItem] {
        Array(clothingItems.prefix(10))
    }

    private var outfitsByOccasion: [(occasion: Occasion, outfits: [Outfit])] {
        Dictionary(grouping: outfits, by: \.occasion)
            .map { (occasion: $0.key, outfits: $0.value) }
            .sorted { $0.outfits.count > $1.outfits.count }
    }

    private var recentlyWornOutfits: [Outfit] {
        outfits
            .filter { $0.lastWornDate != nil }
            .sorted { ($0.lastWornDate ?? .distantPast) > ($1.lastWornDate ?? .distantPast) }
            .prefix(8)
            .map { $0 }
    }

    private var todaysPick: Outfit? {
        outfits.sorted {
            ($0.lastWornDate ?? .distantPast) < ($1.lastWornDate ?? .distantPast)
        }.first
    }

    private var wardrobeUtilization: Int {
        guard !clothingItems.isEmpty else { return 0 }
        let worn = clothingItems.filter { $0.wearCount > 0 }.count
        return Int(Double(worn) / Double(clothingItems.count) * 100)
    }

    private var forgottenItems: [ClothingItem] {
        clothingItems
            .filter { $0.wearCount == 0 }
            .sorted { $0.dateAdded < $1.dateAdded }
            .prefix(10)
            .map { $0 }
    }

    private var topCategories: [(category: ClothingCategory, items: [ClothingItem])] {
        Dictionary(grouping: clothingItems, by: \.category)
            .map { (category: $0.key, items: $0.value) }
            .sorted { $0.items.count > $1.items.count }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // 1. Hero — "Today's Pick"
                    if let pick = todaysPick {
                        heroCard(for: pick)
                    } else {
                        Image(.thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .bottom) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("TODAY'S PICK")
                                            .font(.headline)
                                            .fontWidth(.condensed)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .frame(maxWidth: .infinity)
                            }
                    }

                    // 2. Outfit Groups
                    if !outfitsByOccasion.isEmpty {
                        outfitGroupsSection
                            .padding(.top, 32)
                    }

                    // 3. Calendar CTA Banner
                    calendarCTABanner
                        .padding(.top, 24)

                    // 4. Wardrobe Insights
                    if !clothingItems.isEmpty {
                        wardrobeInsightsSection
                            .padding(.top, 24)
                    }

                    // 5. Recently Worn
                    if !recentlyWornOutfits.isEmpty {
                        recentlyWornSection
                            .padding(.top, 32)
                    }

                    // 6. Rediscover
                    if !forgottenItems.isEmpty {
                        rediscoverSection
                            .padding(.top, 28)
                    }

                    // 7. Category Collections
                    if !topCategories.isEmpty {
                        categoryCollectionsSection
                            .padding(.top, 28)
                    }

                    // 8. Recently Added
                    if !recentItems.isEmpty {
                        recentlyAddedSection
                            .padding(.top, 28)
                    }
                }
            }

            .navigationTitle(Constants.Strings.homeTab)
            .ignoresSafeArea(edges: .top)

            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showOutfitBuilder = true
                    } label: {
                        Label(Constants.Strings.buildOutfit, systemImage: "rectangle.stack.badge.plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showOutfitBuilder) {
                OutfitBuilderView(preselectedOccasion: selectedOccasion)
            }
        }
    }

    // MARK: - Hero Suggestion

    private func heroCard(for outfit: Outfit) -> some View {
        ZStack {
            // Dynamic gradient background based on outfit image colors
            if let imageData = outfit.previewImageData,
               let uiImage = UIImage(data: imageData) {
                // Clear outfit image
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()

                // Content overlay with gradient
                VStack(alignment: .leading) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("TODAY'S PICK")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))

                        Text(outfit.name)
                            .font(.title.bold())
                            .foregroundStyle(.white)

                        HStack(spacing: 12) {
                            Label(outfit.occasion.displayName, systemImage: outfit.occasion.systemImage)
                                .font(.subheadline)

                            if let itemCount = outfit.items?.count {
                                Text("\u{2022}")
                                Text("\(itemCount) items")
                                    .font(.subheadline)
                            }
                        }
                        .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.75), .black.opacity(0.4), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
        }
    }

    // MARK: - Calendar CTA Banner

    private var calendarCTABanner: some View {
        Button {
            showOutfitBuilder = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan Your Week")
                        .font(.subheadline.weight(.medium))
                    Text("Build outfits for the days ahead")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Wardrobe Insights

    private var wardrobeInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wardrobe Insights")
                .font(.title3.weight(.semibold))
                .padding(.horizontal)

            HStack(spacing: 0) {
                statCell(value: "\(clothingItems.count)", label: "Items")
                Divider()
                    .frame(height: 40)
                statCell(value: "\(outfits.count)", label: "Outfits")
                Divider()
                    .frame(height: 40)
                statCell(value: "\(wardrobeUtilization)%", label: "Worn")
            }
            .padding(.vertical, 16)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Outfit Groups (List pattern — primary section)

    private var outfitGroupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Primary header: title2 bold + circle chevron
            HStack {
                Text("Outfit Groups")
                    .font(.title2.weight(.bold))
                Image(systemName: "chevron.right.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(Array(outfitsByOccasion.prefix(4).enumerated()), id: \.element.occasion) { index, group in
                    outfitGroupRow(group.occasion, outfits: group.outfits)

                    if index < min(outfitsByOccasion.count, 4) - 1 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .padding(.vertical, 4)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    private func outfitGroupRow(_ occasion: Occasion, outfits: [Outfit]) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.accent.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: occasion.systemImage)
                            .font(.title3)
                            .foregroundStyle(.accent)
                    }

                Text("\(outfits.count)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.accent)
                    .clipShape(Capsule())
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(occasion.displayName)
                    .font(.subheadline.weight(.medium))

                Text(outfits.map(\.name).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: - Recently Worn (Collection — secondary section)

    private var recentlyWornSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Secondary header: title3 semibold + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("Recently Worn")
                    .font(.title3.weight(.semibold))
                Text("Outfits you've worn lately")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Constants.Layout.hStackItemSpacing) {
                    ForEach(recentlyWornOutfits) { outfit in
                        outfitCollectionItem(outfit)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        }
    }

    // MARK: - Rediscover Section

    private var rediscoverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Rediscover")
                    .font(.title3.weight(.semibold))
                Text("Items you haven't worn yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Constants.Layout.hStackItemSpacing) {
                    ForEach(forgottenItems) { item in
                        categoryItemThumbnail(item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Category Collections (grouped by patterns — tertiary sections)

    private var categoryCollectionsSection: some View {
        VStack(spacing: 20) {
            ForEach(topCategories, id: \.category) { group in
                VStack(alignment: .leading, spacing: 12) {
                    // Tertiary header: headline + item count subtitle
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.category.displayName)
                                .font(.headline)
                            Text("\(group.items.count) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: Constants.Layout.hStackItemSpacing) {
                            ForEach(group.items.prefix(10)) { item in
                                categoryItemThumbnail(item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Recently Added (tertiary section)

    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tertiary header: headline + subtitle
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recently Added")
                        .font(.headline)
                    Text("New in your closet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Constants.Layout.hStackItemSpacing) {
                    ForEach(recentItems) { item in
                        recentItemThumbnail(item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Shared Components

    private func outfitCollectionItem(_ outfit: Outfit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                if let imageData = outfit.previewImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: Constants.Layout.outfitCollectionItemWidth,
                            height: Constants.Layout.outfitCollectionItemHeight
                        )
                        .clipped()
                        .clipShape(.rect(cornerRadius: Constants.Layout.cardCornerRadius))
                } else {
                    RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                        .fill(.secondary.opacity(0.1))
                        .frame(
                            width: Constants.Layout.outfitCollectionItemWidth,
                            height: Constants.Layout.outfitCollectionItemHeight
                        )
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: outfit.occasion.systemImage)
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                                Text("\(outfit.items?.count ?? 0) items")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                }

                // "Wore Today" button
                Button {
                    outfit.markAsWorn()
                    woreOutfitID = outfit.id
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()

                    // Reset visual confirmation after a moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if woreOutfitID == outfit.id {
                            woreOutfitID = nil
                        }
                    }
                } label: {
                    Image(systemName: woreOutfitID == outfit.id ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(woreOutfitID == outfit.id ? .green : .white)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .padding(8)
                .animation(.easeInOut(duration: 0.2), value: woreOutfitID)
            }
            .frame(
                width: Constants.Layout.outfitCollectionItemWidth,
                height: Constants.Layout.outfitCollectionItemHeight
            )

            Text(outfit.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
        }
    }

    /// Medium thumbnails for category collections (120x120)
    private func categoryItemThumbnail(_ item: ClothingItem) -> some View {
        VStack(spacing: 6) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: Constants.Layout.categoryItemSize,
                        height: Constants.Layout.categoryItemSize
                    )
                    .clipped()
                    .clipShape(.rect(cornerRadius: Constants.Layout.cardCornerRadius))
            } else {
                RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                    .fill(.secondary.opacity(0.1))
                    .frame(
                        width: Constants.Layout.categoryItemSize,
                        height: Constants.Layout.categoryItemSize
                    )
                    .overlay {
                        Image(systemName: item.category.systemImage)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }

            Text(item.name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: Constants.Layout.categoryItemSize)
        }
    }

    /// Small thumbnails for recently added (80x80)
    private func recentItemThumbnail(_ item: ClothingItem) -> some View {
        VStack(spacing: 6) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: Constants.Layout.recentItemSize,
                        height: Constants.Layout.recentItemSize
                    )
                    .clipped()
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.1))
                    .frame(
                        width: Constants.Layout.recentItemSize,
                        height: Constants.Layout.recentItemSize
                    )
                    .overlay {
                        Image(systemName: item.category.systemImage)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
            }

            Text(item.name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: Constants.Layout.recentItemSize)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewData.previewContainer)
}
