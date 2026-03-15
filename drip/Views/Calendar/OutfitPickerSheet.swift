//
//  OutfitPickerSheet.swift
//  drip
//

import SwiftData
import SwiftUI

struct OutfitPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Outfit.dateCreated, order: .reverse) private var outfits: [Outfit]

    let date: Date

    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if outfits.isEmpty {
                    ContentUnavailableView(
                        Constants.Strings.emptyOutfitsTitle,
                        systemImage: "rectangle.stack",
                        description: Text(Constants.Strings.emptyOutfitsMessage)
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(outfits) { outfit in
                                outfitTile(outfit)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(Constants.Strings.planOutfit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func outfitTile(_ outfit: Outfit) -> some View {
        Button {
            let log = OutfitLog(type: .planned, date: date, outfit: outfit)
            modelContext.insert(log)
            try? modelContext.save()
            dismiss()
        } label: {
            VStack(spacing: 8) {
                if let imageData = outfit.previewImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
                } else {
                    RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                        .fill(.secondary.opacity(0.1))
                        .frame(height: 160)
                        .overlay {
                            VStack(spacing: 6) {
                                Image(systemName: outfit.occasion?.systemImage ?? "questionmark")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("\(outfit.items?.count ?? 0) items")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                }

                Text(outfit.name)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OutfitPickerSheet(date: Date())
        .modelContainer(PreviewData.previewContainer)
}
