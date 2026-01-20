//
//  ClothingItemCard.swift
//  drip
//

import SwiftUI

struct ClothingItemCard: View {
    let item: ClothingItem
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            itemImage
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Text(item.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Circle()
                    .fill(item.color.color)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .strokeBorder(.secondary.opacity(0.3), lineWidth: 1)
                    )

                Spacer()

                if item.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .glassEffect(
            isSelected ? .regular.tint(.accentColor) : .regular,
            in: .rect(cornerRadius: Constants.Layout.cardCornerRadius)
        )
    }

    @ViewBuilder
    private var itemImage: some View {
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                item.color.color.opacity(0.3)
                Image(systemName: item.category.systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
        ClothingItemCard(
            item: PreviewData.sampleClothingItems[0]
        )
        ClothingItemCard(
            item: PreviewData.sampleClothingItems[1],
            isSelected: true
        )
    }
    .padding()
}
