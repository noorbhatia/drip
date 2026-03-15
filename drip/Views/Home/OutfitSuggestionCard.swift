//
//  OutfitSuggestionCard.swift
//  drip
//

import SwiftData
import SwiftUI

struct OutfitSuggestionCard: View {
    let occasion: Occasion
    let description: String
    let image: String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: Constants.Layout.heroCardHeight)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Tier 1: Small caps label
                        Text("PICK FOR YOU")
                            .font(.caption.weight(.semibold))
                            .opacity(0.8)

                        // Tier 2: Bold title
                        Text(occasion.displayName)
                            .font(.title2.weight(.bold))

                        // Tier 3: Muted description
                        Text(description)
                            .font(.subheadline)
                            .opacity(0.85)
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.6), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                .clipShape(.rect(cornerRadius: Constants.Layout.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(occasion.displayName) outfit suggestion: \(description)")
    }
}

#Preview {
    ScrollView {
        OutfitSuggestionCard(
            occasion: Occasion(name: Occasion.Names.casual, displayName: "Casual", systemImage: "sun.max", suggestionDescription: "Relaxed", sortOrder: 0),
            description: "Relaxed and comfortable for everyday",
            image: "thumbnail"
        )
        .padding(.horizontal)
    }
    .modelContainer(PreviewData.previewContainer)
}
