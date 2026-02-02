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
    let editorData: EditorData
    var onSave: (() -> Void)?

    @Query private var allItems: [ClothingItem]

    @State private var outfitName = ""
    @State private var selectedOccasion: Occasion = .casual
    @State private var notes = ""
    @State private var isSaving = false
    @State private var previewImage: UIImage?

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
                if isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        saveOutfit()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .task {
            let canvasRect = CGRect(origin: .zero, size: editorData.canvasSize)
            previewImage = await editorData.exportAsImage(canvasRect)
        }
    }

    private var previewSection: some View {
        Section {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
            }
        }
        .listRowInsets(EdgeInsets())
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
        isSaving = true

        Task { @MainActor in
            // Export canvas as image
            let canvasRect = CGRect(origin: .zero, size: editorData.canvasSize)
            let canvasImage = await editorData.exportAsImage(canvasRect)

            let outfit = Outfit(
                name: outfitName.trimmingCharacters(in: .whitespacesAndNewlines),
                occasion: selectedOccasion,
                notes: notes.isEmpty ? nil : notes,
                items: selectedItems,
                previewImageData: canvasImage?.pngData()
            )

            modelContext.insert(outfit)
            isSaving = false
            onSave?()
        }
    }
}

#Preview {
    NavigationStack {
        SaveOutfitView(selectedItemIds: [], editorData: EditorData())
    }
    .modelContainer(PreviewData.previewContainer)
}
