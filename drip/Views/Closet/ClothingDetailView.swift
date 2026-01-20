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

    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                itemImage
                detailsCard
                statsCard
                tagsSection
                notesSection
            }
            .padding()
            .padding(.bottom, 60)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
                    .fill(item.color.color.opacity(0.3))
                    .frame(height: 300)

                Image(systemName: item.category.systemImage)
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
            }
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
        }
    }

    private var detailsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(item.category.displayName, systemImage: item.category.systemImage)
                            .font(.body.weight(.medium))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Color")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.color.color)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.secondary.opacity(0.3), lineWidth: 1)
                                )
                            Text(item.color.displayName)
                                .font(.body.weight(.medium))
                        }
                    }
                }

                if let brand = item.brand {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Brand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(brand)
                            .font(.body.weight(.medium))
                    }
                }
            }
            .padding()
        }
    }

    private var statsCard: some View {
        GlassCard {
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
            .padding()
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
    private var tagsSection: some View {
        if !item.tags.isEmpty {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tags")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.secondary.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
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
