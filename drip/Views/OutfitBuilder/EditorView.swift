//
//  EditorView.swift
//  drip
//
//  Created by Noor Bhatia on 26/01/26.
//

import SwiftUI
import PaperKit
import PencilKit

struct EditorView: View {
    var size:CGSize
    @State var data: EditorData
    
    init(size: CGSize, data: EditorData) {
        self.size = size
        self._data = .init(initialValue: data)
    }
    var body: some View {
        if let controller = data.controller {
            PaperControllerView(controller: controller)
        } else {
            ProgressView()
                .onAppear {
                    data.initializeController(.init(origin: .zero, size: size))
                }
        }
    }
}

/// Paper Controller View
fileprivate struct PaperControllerView: UIViewControllerRepresentable {
    var controller: PaperMarkupViewController

    func makeUIViewController(context: Context) -> some UIViewController {
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No updates needed - background is handled via contentView
    }
}

    
import PhotosUI

struct EditCanvasPreview: View {
    @State private var data = EditorData()
    @State private var showTools:Bool = false
    @State private var showImagePicker:Bool = false
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack{
            EditorView(size: .init(width: 350, height: 670), data: data)
                .toolbar {
                    MenuItems()
                    Button("Export", systemImage: "square.and.arrow.up.fill"){
                        Task{
                            let rect = CGRect(origin: .zero, size: .init(width: 350, height: 670))
                            if let image = await data.exportAsImage(rect){
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                        }
                    }
                }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { oldValue, newValue in
            guard let newValue else { return }
            Task {
                guard let data = try? await newValue.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    return
                }
                self.data.insertImage(image, rect: .init(origin: .zero, size: .init(width: 100, height: 100)))
                photoItem = nil
            }
        }
    }
    
    @ViewBuilder
    func MenuItems() -> some View {
        Menu("Items"){
            Button("text"){
                data.insertText(.init(string: "Helloooo"), rect: .zero)
            }
            
            Menu("Shape"){
                let rect = CGRect(origin: .zero, size: .init(width: 100, height: 100))

                Button("Rectangle"){
                    let config = ShapeConfiguration(type: .rectangle)
                    data.insertShape(config, rect: rect)
                }
            }
            
            Button("Image"){
                
            }
            
            Button(showTools ? "Hide" : "Show"){
                 showTools.toggle()
                data.showPencilKitTools(showTools)
            }
        
        }
    }
}

#Preview {
    EditCanvasPreview()
}
