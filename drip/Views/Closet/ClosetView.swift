//
//  ClosetView.swift
//  drip
//

import SwiftData
import SwiftUI
import PhotosUI

struct ClosetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var allItems: [ClothingItem]
    
    @State private var searchText = ""
    @State private var selectedCategory: ClothingCategory?
    @State private var showAddClothing = false
    @State private var imageSelections: [PhotosPickerItem] = []
    @State private var selectedImageData: Data?
    @State private var showPhotosPicker = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage? = nil
    @State private var isImporting = false
    @State private var importProgress: (current: Int, total: Int)?

    private var filteredItems: [ClothingItem] {
        var items = allItems
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            items = items.filter { item in
                item.name.lowercased().contains(lowercasedQuery) ||
                item.brand?.lowercased().contains(lowercasedQuery) == true ||
                item.tags.contains { $0.lowercased().contains(lowercasedQuery) }
            }
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if allItems.isEmpty {
                    EmptyStateView(
                        title: Constants.Strings.emptyClosetTitle,
                        message: Constants.Strings.emptyClosetMessage,
                        systemImage: "cabinet",
                        action: { showAddClothing = true },
                        actionTitle: "Add First Item"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ClosetFilterView(selectedCategory: $selectedCategory)
                                .padding(.top, 8)
                            
                            if filteredItems.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                                    .padding(.top, 60)
                            } else {
                                ClothingGridView(items: filteredItems)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(Constants.Strings.closetTab)
            .toolbarTitleDisplayMode(.inlineLarge)
            .searchable(text: $searchText, prompt: "Search your closet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ClothingImageSourceView()
                }
            }
            .onChange(of: imageSelections) { _, newItems in
                guard !newItems.isEmpty else { return }

                Task {
                    if newItems.count == 1 {
                        // Single image: load, remove background, and open AddClothingView
                        if let data = try? await newItems.first?.loadTransferable(type: Data.self) {
                            let processedData = (try? await BackgroundRemover.removeBackground(from: data)) ?? data
                            selectedImageData = processedData
                            showAddClothing = true
                        }
                    } else {
                        // Multiple images: process in background with progress tracking
                        isImporting = true
                        importProgress = (0, newItems.count)
                        await importMultipleImages(newItems)
                        importProgress = nil
                        isImporting = false
                    }
                    // Clear selection for next pick
                    imageSelections = []
                }
            }
            .photosPicker(
                isPresented: $showPhotosPicker,
                selection: $imageSelections,
                maxSelectionCount: nil,
                matching: .images,
                photoLibrary: .shared()
            )
            .sheet(isPresented: $showAddClothing, onDismiss: {
                selectedImageData = nil
            }) {
                AddClothingView(initialImageData: selectedImageData)
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { _, newImage in
                guard let image = newImage else { return }
                Task {
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        let processedData = (try? await BackgroundRemover.removeBackground(from: data)) ?? data
                        selectedImageData = processedData
                        showAddClothing = true
                    }
                    capturedImage = nil
                }
            }
            .overlay {
                if isImporting {
                    ImportingOverlayView(progress: importProgress)
                }
            }
        }
    }
    
    @ViewBuilder
    func ClothingImageSourceView () -> some View{
        Menu {
            Button("Camera", systemImage: "camera") {
                showCamera = true
            }

            Button {
                showPhotosPicker = true
            } label: {
                Label("Photos", systemImage: "photo")
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    private func importMultipleImages(_ items: [PhotosPickerItem]) async {
        var processedImages: [Data] = []

        // Process each image sequentially to track progress
        for (index, item) in items.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Remove background from each image
                let processedData = (try? await BackgroundRemover.removeBackground(from: data)) ?? data
                processedImages.append(processedData)
            }
            // Update progress on main actor
            importProgress = (index + 1, items.count)
        }

        // Insert into SwiftData on background thread via @ModelActor
        let actor = ClothingImportActor(modelContainer: modelContext.container)

        do {
            try await actor.importClothingItems(from: processedImages)
        } catch {
            print("Failed to import items: \(error)")
        }
    }
}

// MARK: - Importing Overlay View

struct ImportingOverlayView: View {
    var progress: (current: Int, total: Int)?


    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                // Ripple card
                VStack(spacing: 16) {
                    Image(systemName: "tshirt.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)

                    Text("Removing backgrounds...")
                        .font(.headline)
                        .foregroundStyle(.white)

                    if let progress {
                        Text("\(progress.current) of \(progress.total)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))

                        ProgressView(value: Double(progress.current), total: Double(progress.total))
                            .tint(.white)
                            .frame(width: 200)
                    }
                }
                .padding(32)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                }
            }
        }
    }
}


#Preview {
    ClosetView()
        .modelContainer(PreviewData.previewContainer)
}
