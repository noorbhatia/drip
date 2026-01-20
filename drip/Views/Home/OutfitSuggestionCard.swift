//
//  OutfitSuggestionCard.swift
//  drip
//

import SwiftUI

struct OutfitSuggestionCard: View {
    let occasion: Occasion
    let description: String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.accent.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: occasion.systemImage)
                        .font(.title2)
                        .foregroundStyle(.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(occasion.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(width: 140, alignment: .leading)
            .padding()
            
        }
        .border(.accent)
        .buttonBorderShape(.roundedRectangle(radius: Constants.Layout.cardCornerRadius))
        
        
    }
}

#Preview {
    HStack {
        OutfitSuggestionCard(
            occasion: .casual,
            description: "Relaxed and comfortable for everyday"
        )
        OutfitSuggestionCard(
            occasion: .work,
            description: "Professional and polished"
        )
    }
    .padding()
}
