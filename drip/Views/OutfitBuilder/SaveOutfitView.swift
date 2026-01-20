//
//  SaveOutfitView.swift
//  drip
//

import SwiftData
import SwiftUI

struct SaveOutfitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let selectedItemIds: Set<UUID>
    var onSave: (() -> Void)?

    @Query private var allItems: [ClothingItem]

    @State private var outfitName = ""
    @State private var selectedOccasion: Occasion = .casual
    @State private var notes = ""

    private var selectedItems: [ClothingItem] {
        allItems.filter { selectedItemIds.contains($0.id) }
    }

    private var isFormValid: Bool {
        !outfitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            previewSection
            detailsSection
            occasionSection
            notesSection
        }
        .navigationTitle("Save Outfit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveOutfit()
                }
                .disabled(!isFormValid)
            }
        }
    }

    private var previewSection: some View {
        Section("Preview") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedItems) { item in
                        itemThumbnail(item)
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            Text("\(selectedItems.count) items selected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func itemThumbnail(_ item: ClothingItem) -> some View {
        VStack(spacing: 6) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.color.color.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Image(systemName: item.category.systemImage)
                        .foregroundStyle(.secondary)
                }
            }

            Text(item.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Outfit Name", text: $outfitName)
        }
    }

    private var occasionSection: some View {
        Section("Occasion") {
            Picker("Occasion", selection: $selectedOccasion) {
                ForEach(Occasion.allCases) { occasion in
                    Label(occasion.displayName, systemImage: occasion.systemImage)
                        .tag(occasion)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Add notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private func saveOutfit() {
        let outfit = Outfit(
            name: outfitName.trimmingCharacters(in: .whitespacesAndNewlines),
            occasion: selectedOccasion,
            notes: notes.isEmpty ? nil : notes,
            items: selectedItems
        )

        modelContext.insert(outfit)
        onSave?()
    }
}

#Preview {
    NavigationStack {
        SaveOutfitView(selectedItemIds: [])
    }
    .modelContainer(PreviewData.previewContainer)
}
