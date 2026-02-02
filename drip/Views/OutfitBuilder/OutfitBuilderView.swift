//
//  OutfitBuilderView.swift
//  drip
//

import SwiftData
import SwiftUI

struct OutfitBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [ClothingItem]

    var preselectedOccasion: Occasion?

    @State private var currentStep: BuilderStep = .selectItems
    @State private var selectedItemIds: Set<UUID> = []
    @State private var navigationPath = NavigationPath()
    @State private var editorData = EditorData()

    enum BuilderStep: Int, CaseIterable {
        case selectItems
        case arrange
        case save

        var title: String {
            switch self {
            case .selectItems: return "Select Items"
            case .arrange: return "Preview"
            case .save: return "Save"
            }
        }
    }

    private var selectedItems: [ClothingItem] {
        allItems.filter { selectedItemIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                stepContent
            }
            .navigationTitle(currentStep == .arrange ? "" : "Build Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if currentStep == .arrange {
                        Button {
                            withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
                                currentStep = .selectItems
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Next") {
                        advanceStep()
                    }
                    .disabled(selectedItemIds.isEmpty)
                }
            }
            .navigationDestination(for: BuilderStep.self) { step in
                if step == .save {
                    SaveOutfitView(
                        selectedItemIds: selectedItemIds,
                        editorData: editorData,
                        onSave: { dismiss() }
                    )
                }
            }
        }
    }

   

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .selectItems:
            ClothingPickerView(selectedItems: $selectedItemIds)
        case .arrange:
            arrangeView
        case .save:
            EmptyView()
        }
    }

    private var arrangeView: some View {
        OutfitEditorView(
            selectedItemIds: selectedItemIds,
            onAddClothes: {
                withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
                    currentStep = .selectItems
                }
            },
            editorData: editorData
        )
    }

    private func advanceStep() {
        withAnimation(.snappy(duration: Constants.Animation.snappyDuration)) {
            switch currentStep {
            case .selectItems:
                currentStep = .arrange
            case .arrange:
                currentStep = .save
                navigationPath.append(BuilderStep.save)
            case .save:
                break
            }
        }
    }
}

#Preview {
    OutfitBuilderView()
        .modelContainer(PreviewData.previewContainer)
}
