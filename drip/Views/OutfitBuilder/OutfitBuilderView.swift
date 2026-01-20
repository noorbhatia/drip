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
                progressIndicator
                    .padding(.horizontal)
                    .padding(.top, 8)

                stepContent
            }
            .navigationTitle("Build Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    if currentStep != .save {
                        Button(currentStep == .selectItems ? "Next" : "Save") {
                            advanceStep()
                        }
                        .disabled(selectedItemIds.isEmpty)
                    }
                }
            }
            .navigationDestination(for: BuilderStep.self) { step in
                if step == .save {
                    SaveOutfitView(
                        selectedItemIds: selectedItemIds,
                        onSave: { dismiss() }
                    )
                }
            }
        }
    }

    private var progressIndicator: some View {
        HStack(spacing: 4) {
            ForEach(Array(BuilderStep.allCases.enumerated()), id: \.element) { index, step in
                if index > 0 {
                    Rectangle()
                        .fill(currentStep.rawValue >= step.rawValue ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(height: 2)
                }

                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(currentStep.rawValue >= step.rawValue ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 28, height: 28)

                        if currentStep.rawValue > step.rawValue {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(currentStep.rawValue >= step.rawValue ? .white : .secondary)
                        }
                    }

                    Text(step.title)
                        .font(.caption2)
                        .foregroundStyle(currentStep == step ? .primary : .secondary)
                }
            }
        }
        .padding(.vertical, 12)
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
        VStack(spacing: 16) {
            Text("Your outfit preview")
                .font(.headline)
                .padding(.top)

            if selectedItems.isEmpty {
                Spacer()
                Text("No items selected")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 100, maximum: 150))],
                        spacing: 16
                    ) {
                        ForEach(selectedItems) { item in
                            VStack(spacing: 8) {
                                itemPreview(item)
                                    .frame(height: 120)

                                Text(item.name)
                                    .font(.caption)
                                    .lineLimit(1)

                                Button {
                                    selectedItemIds.remove(item.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }

            HStack {
                Button {
                    currentStep = .selectItems
                } label: {
                    Label("Edit Selection", systemImage: "pencil")
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("\(selectedItems.count) items")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func itemPreview(_ item: ClothingItem) -> some View {
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.color.color.opacity(0.3))

                Image(systemName: item.category.systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
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
