//
//  RecentOutfitsSection.swift
//  drip
//

import SwiftUI

struct RecentOutfitsSection: View {
    let outfits: [Outfit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Outfits")
                .font(.title3.weight(.semibold))
                .padding(.horizontal)

            if outfits.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(outfits) { outfit in
                            OutfitCard(outfit: outfit)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.stack")
                .font(.title)
                .foregroundStyle(.secondary)

            Text("No outfits yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Build your first outfit!")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .padding(.horizontal)
    }
}

struct OutfitCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: outfit.occasion.systemImage)
                    .font(.title2)
                    .foregroundStyle(.accent)

                Spacer()

                if outfit.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(outfit.occasion.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(outfit.items?.count ?? 0) items")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 130)
        .padding()
        .background(.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
    }
}

#Preview {
    RecentOutfitsSection(outfits: [])
        .padding(.vertical)
}
