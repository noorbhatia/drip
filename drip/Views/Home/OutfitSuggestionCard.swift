//
//  OutfitSuggestionCard.swift
//  drip
//

import SwiftUI

struct OutfitSuggestionCard: View {
    let occasion: Occasion
    let description: String
    let image:String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            Image(image)
                .resizable()
//                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .overlay(alignment: .bottom) {
                    HStack {
                        Text("Your outfit for today\nThis a cool outfit \nsdfssdf")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.leading, 8)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                bottomLeading: Constants.Layout.cardCornerRadius,
                                bottomTrailing: Constants.Layout.cardCornerRadius
                            )
                        )
                        .background(.ultraThinMaterial)
                    )
                    
                }

                .clipShape(.rect(cornerRadius: Constants.Layout.cardCornerRadius))
        }
        .frame(width: 200, height: 250)
        .buttonStyle(.plain)
        .buttonBorderShape(.roundedRectangle(radius: Constants.Layout.cardCornerRadius))
//        .background(.green)
        .accessibilityLabel("\(occasion.displayName) outfit suggestion")
    }
}

#Preview {
    ScrollView (.horizontal){
        LazyHStack(spacing: 20) {
            OutfitSuggestionCard(
                occasion: .casual,
                description: "Relaxed and comfortable for everyday",
                image: "thumbnail"
            )
            
            OutfitSuggestionCard(
                occasion: .work,
                description: "Professional and polished",
                image: "thumbnail_2"

            )
            OutfitSuggestionCard(
                occasion: .work,
                description: "Professional and polished",
                image: "thumbnail_3"

            )
        }
        .scrollTargetLayout()
        .padding(.horizontal)

    }
    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))

}
