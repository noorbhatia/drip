//
//  OutfitEditorView.swift
//  drip
//

import SwiftUI
import SwiftData

struct OutfitEditorView: View {
    let selectedItemIds: Set<UUID>
    var onAddClothes: () -> Void
    @Bindable var editorData: EditorData

    @Query private var allItems: [ClothingItem]
    @State private var showBackgroundPicker = false
    @State private var showPencilKit = false
    @State private var canvasSize: CGSize = .zero

    private var selectedClothingItems: [ClothingItem] {
        allItems.filter { selectedItemIds.contains($0.id) }
    }

    var body: some View {
        VStack {
            // PaperKit canvas
            GeometryReader { geometry in
                ZStack {
                    // PaperKit editor (now handles its own background color)
                    if editorData.controller != nil {
                        EditorView(size: geometry.size, data: editorData)
                          
                    } else {
                        // Fallback background for loading state
                        editorData.backgroundColor
                            
                        ProgressView()
                    }
                }
                .onAppear {
                    canvasSize = geometry.size
                    editorData.initializeForOutfitBuilder(
                        CGRect(origin: .zero, size: geometry.size),
                        items: selectedClothingItems
                    )
                }
                .onChange(of: selectedItemIds) { _, _ in
                    editorData.syncWithSelection(
                        selectedClothingItems,
                        rect: CGRect(origin: .zero, size: canvasSize)
                    )
                }
            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 8)

           
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .ignoresSafeArea()
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showPencilKit.toggle()
                } label: {
                    Image(systemName: "pencil.tip")
                }
            }
            
            ToolbarSpacer(.flexible, placement: .topBarTrailing)
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItemGroup(placement: .bottomBar) {
                
                Button {
                    onAddClothes()
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    showBackgroundPicker = true

                } label: {
                    Image(systemName: "paintpalette")
                }
            }
            
        }
        .onChange(of: showPencilKit, { oldValue, newValue in
            editorData.showPencilKitTools(newValue)
        })
        .sheet(isPresented: $showBackgroundPicker) {
            BackgroundColorPicker(selectedColor: Binding(
                get: { editorData.backgroundColor },
                set: { editorData.setBackgroundColor($0) }
            ))
            .presentationDetents([.height(320)])
        }
    }

    private var toolbar: some View {
        HStack(spacing: 32) {
            
            toolbarButton(icon: "paintpalette", label: "Background") {
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    private func toolbarButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(.primary)
            .frame(minWidth: 44, minHeight: 44)
        }
        .sensoryFeedback(.selection, trigger: label)
    }
}

#Preview {
    OutfitEditorView(
        selectedItemIds: [],
        onAddClothes: {},
        editorData: EditorData()
    )
    .modelContainer(PreviewData.previewContainer)
}
