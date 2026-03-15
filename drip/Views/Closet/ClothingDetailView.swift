//
//  ClothingDetailView.swift
//  drip
//

import SwiftData
import SwiftUI

struct ClothingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: ClothingItem

    @Query(sort: \WardrobeColor.sortOrder) private var allColors: [WardrobeColor]

    @State private var showDeleteConfirmation = false
    @State private var showRenameItemModal: Bool = false
    @State private var renameText = ""

    var body: some View {

            List {
                itemImage
                    .listRowBackground(Color.clear)
                    .listRowInsets(.all, 0)

                Section {
                    LazyVGrid(
                        columns: [
                            GridItem(),
                            GridItem(),
                            GridItem(),
                            GridItem(),
                            GridItem(),
                            GridItem(),
                        ]
                    ) {
                        ForEach(allColors) { color in
                            Circle()
                                .fill(color.isMulticolor
                                    ? AnyShapeStyle(AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red], center: .center))
                                    : AnyShapeStyle(color.swiftUIColor))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .strokeBorder(item.wardrobeColor === color ? Color.accentColor : .secondary.opacity(0.3), lineWidth: 2)
                                )
                                .onTapGesture {
                                    item.wardrobeColor = color
                                }
                        }
                    }
                }

                Section {
                    LabeledContent("Type") {
                        Picker("", selection: $item.category) {
                            ForEach(ClothingCategory.allCases) { category in
                                Label(category.displayName, systemImage: category.systemImage)
                                    .tag(category)
                            }
                        }
                    }



                    LabeledContent("Brand") {
                        Picker("", selection: $item.brand) {
                            Text("None").tag(Brand?.none)
                            ForEach(Brand.defaults, id: \.name) { brand in
                                Label(brand.name, systemImage: brand.icon)
                                    .tag(Brand?(Brand(name: brand.name, icon: brand.icon)))
                            }
                        }
                    }
                   
                    LabeledContent("Price") {
                        TextField("",value: $item.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .keyboardType(.numberPad)
                    }

                }

                Section {
                    statsCard
                }
            }
//            .listStyle(.grouped)
//            .padding()
//            .padding(.bottom, 60)

            .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                    Text(item.name)
                    .onTapGesture {
                        withAnimation {
                            showRenameItemModal = true
                        }
                    }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        item.isFavorite.toggle()
                    } label: {
                        Label(
                            item.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: item.isFavorite ? "heart.slash" : "heart"
                        )
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Rename item", isPresented: $showRenameItemModal){
            TextField(item.name, text: $renameText)
           
            Button(role: .cancel){
                showRenameItemModal = false
            }
            Button("Save") {
                item.name = renameText
                showRenameItemModal = false
            }
            
        }
        .toolbar(.hidden, for: .tabBar)
        .confirmationDialog("Delete Item", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteItem()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this item? This action cannot be undone.")
        }
    }

    @ViewBuilder
    private var itemImage: some View {
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill((item.wardrobeColor?.swiftUIColor ?? .gray).opacity(0.3))
                    .frame(height: 300)

                Image(systemName: item.category.systemImage)
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsCard: some View {

            HStack {
                statItem(title: "Times Worn", value: "\(item.wearCount)", icon: "repeat")

                Divider()
                    .frame(height: 40)

                statItem(
                    title: "Added",
                    value: item.dateAdded.formatted(date: .abbreviated, time: .omitted),
                    icon: "calendar"
                )

                if let lastWorn = item.lastWornDate {
                    Divider()
                        .frame(height: 40)

                    statItem(
                        title: "Last Worn",
                        value: lastWorn.formatted(date: .abbreviated, time: .omitted),
                        icon: "clock"
                    )
                }
            }

    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }



    @ViewBuilder
    private var notesSection: some View {
        if let notes = item.notes, !notes.isEmpty {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(notes)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ClothingDetailView(item: PreviewData.sampleClothingItems[0])
    }
    .modelContainer(PreviewData.previewContainer)
}
