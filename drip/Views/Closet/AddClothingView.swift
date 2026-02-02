//
//  AddClothingView.swift
//  drip
//

import PhotosUI
import SwiftData
import SwiftUI

struct AddClothingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Optional initial image data passed from PhotosPicker
    var initialImageData: Data? = nil

    @State private var name = ""
    @State private var selectedCategory: ClothingCategory = .tops
    @State private var selectedColor: WardrobeColor = .black
    @State private var brand = ""
    @State private var notes = ""
    @State private var tags: [String] = []
    @State private var newTag = ""

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var rippleTrigger = 0

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                detailsSection
                categorySection
                colorSection
                tagsSection
                notesSection
            }
            .navigationTitle("Add Clothing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(!isFormValid)
                }
            }
            .task {
                if let data = initialImageData {
                    selectedImageData = data
                }
            }
        }
    }

    private var photoSection: some View {
        Section {
            VStack {
                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                    GeometryReader { geometry in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                           
                    }
                    .frame(height: 200)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.secondary.opacity(0.1))
                            .frame(height: 200)

                        VStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                            Text("Add Photo")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label(selectedImageData == nil ? "Select Photo" : "Change Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    rippleTrigger += 1  // Trigger ripple once
                    let processedData = (try? await BackgroundRemover.removeBackground(from: data)) ?? data
                    selectedImageData = processedData
                }
            }
        }
        .listRowBackground(Color.clear)
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Name", text: $name)
            TextField("Brand (optional)", text: $brand)
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(ClothingCategory.allCases) { category in
                    Label(category.displayName, systemImage: category.systemImage)
                        .tag(category)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var colorSection: some View {
        Section("Color") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                ForEach(WardrobeColor.allCases) { color in
                    colorButton(for: color)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func colorButton(for color: WardrobeColor) -> some View {
        Button {
            selectedColor = color
        } label: {
            ZStack {
                if color == .multicolor {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                center: .center
                            )
                        )
                } else {
                    Circle()
                        .fill(color.color)
                }

                Circle()
                    .strokeBorder(
                        selectedColor == color ? Color.accentColor : Color.secondary.opacity(0.3),
                        lineWidth: selectedColor == color ? 3 : 1
                    )

                if selectedColor == color {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color == .white || color == .cream || color == .beige ? .black : .white)
                }
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedColor)
        .accessibilityLabel(color.displayName)
        .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
    }

    private var tagsSection: some View {
        Section("Tags") {
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    tagChip(tag)
                }
            }

            HStack {
                TextField("Add tag", text: $newTag)
                    .textInputAutocapitalization(.never)

                Button {
                    addTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func tagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)

            Button {
                tags.removeAll { $0 == tag }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.secondary.opacity(0.15))
        .clipShape(Capsule())
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Add notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else { return }
        tags.append(trimmedTag)
        newTag = ""
    }

    private func saveItem() {
        let item = ClothingItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: selectedImageData,
            category: selectedCategory,
            color: selectedColor,
            tags: tags,
            brand: brand.isEmpty ? nil : brand,
            notes: notes.isEmpty ? nil : notes
        )

        modelContext.insert(item)
        dismiss()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                maxHeight = max(maxHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + maxHeight)
        }
    }
}

#Preview {
    AddClothingView()
        .modelContainer(PreviewData.previewContainer)
}
