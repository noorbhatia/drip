//
//  EditorData.swift
//  drip
//
//  Created by Noor Bhatia on 26/01/26.
//

import SwiftUI
import PencilKit
import PaperKit

@Observable
class EditorData {
    var controller: PaperMarkupViewController?
    var markup: PaperMarkup?
    var toolPicker = PKToolPicker()
    var backgroundColor: Color = .clear
    var canvasSize: CGSize = .zero
    var contentView: UIView?

    func initializeController(_ rect: CGRect)  {
        let controller = PaperMarkupViewController(supportedFeatureSet: .latest)
        let markup = PaperMarkup(bounds: rect)
        
        self.markup = markup
        self.controller = controller
    }
    
    /// Inserts Text
    func insertText(_ text: NSAttributedString, rect: CGRect) {
        markup?.insertNewTextbox(attributedText: text, frame: rect)
        refreshController()
    }
    
    func insertImage(_ image: UIImage, rect :CGRect){
        guard let cgImage = image.cgImage else { return }
        markup?.insertNewImage(cgImage, frame: rect)
        refreshController()
    }
    
    func insertShape(_ type: ShapeConfiguration, rect: CGRect){
        markup?.insertNewShape(configuration: type, frame: rect)
        refreshController()
    }
    
    func showPencilKitTools(_ isVisible: Bool) {
        guard let controller else { return }
        //Type 1
//        controller.view.pencilKitResponderState.activeToolPicker = toolPicker
//        controller.view.pencilKitResponderState.toolPickerVisibility = isVisible ? .visible : .hidden
        
        //Type 2
        toolPicker.addObserver(controller)
        toolPicker.setVisible(isVisible , forFirstResponder: controller.view)
        
        if isVisible {
            controller.view.becomeFirstResponder()
        }
        
    }
    
    func refreshController() {
        controller?.markup = markup
    }

    // MARK: - Outfit Builder Integration

    /// Initialize the canvas with clothing items for the outfit builder
    func initializeForOutfitBuilder(_ rect: CGRect, items: [ClothingItem]) {
        var featureSet: FeatureSet = .latest
        featureSet.insert(.stickers)
        let controller = PaperMarkupViewController(supportedFeatureSet: featureSet)
        let markup = PaperMarkup(bounds: rect)

        self.markup = markup
        self.controller = controller
        self.canvasSize = rect.size

        // Set the background color using contentView
        updateContentView()

        // Insert each clothing item image
        let itemCount = items.count
        guard itemCount > 0 else {
            refreshController()
            return
        }

        // Calculate scaled sizes for all items first to determine layout
        let maxDimension = Constants.Canvas.maxItemDimension
        var itemSizes: [CGSize] = []
        var validItems: [(item: ClothingItem, uiImage: UIImage, cgImage: CGImage)] = []

        for item in items {
            guard let imageData = item.imageData,
                  let uiImage = UIImage(data: imageData),
                  let cgImage = uiImage.cgImage else { continue }

            let size = scaledSize(for: uiImage, maxDimension: maxDimension)
            itemSizes.append(size)
            validItems.append((item, uiImage, cgImage))
        }

        guard !validItems.isEmpty else {
            refreshController()
            return
        }

        // Calculate total height needed and vertical spacing
        let totalItemHeight = itemSizes.reduce(0) { $0 + $1.height }
        let availableSpacing = rect.height - totalItemHeight
        let spacingCount = CGFloat(validItems.count + 1)
        let verticalSpacing = min(availableSpacing / spacingCount, 50)

        // Start position
        var currentY = verticalSpacing

        for (index, validItem) in validItems.enumerated() {
            let itemSize = itemSizes[index]
            let position = CGPoint(
                x: rect.midX - itemSize.width / 2,
                y: currentY
            )
            let itemRect = CGRect(origin: position, size: itemSize)

            self.markup?.insertNewImage(validItem.cgImage, frame: itemRect)
            currentY += itemSize.height + verticalSpacing
        }

        refreshController()
    }

    /// Sync the canvas when the item selection changes
    func syncWithSelection(_ items: [ClothingItem], rect: CGRect) {
        initializeForOutfitBuilder(rect, items: items)
    }

    /// Set the background color for the canvas
    func setBackgroundColor(_ color: Color) {
        backgroundColor = color
        updateContentView()
    }

    /// Create or update the background view with the current color
    private func updateContentView() {
        guard let controller = controller else { return }
        let backgroundView = UIView(frame: CGRect(origin: .zero, size: canvasSize))
        backgroundView.backgroundColor = UIColor(backgroundColor)
        controller.contentView = backgroundView
        contentView = backgroundView
    }
    
    func exportAsImage(_ rect: CGRect, scale: CGFloat = 1) async -> UIImage? {
        guard let context = makeCGContext(size: rect.size, scale: scale), let markup = controller?.markup else {
            return nil
        }

        // Fill background with selected color
        context.setFillColor(UIColor(backgroundColor).cgColor)
        context.fill(rect)

        await markup.draw(in: context, frame: rect)

        guard let cgImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
    
    func exportAsData() async -> Data?{
        do {
            return try await markup?.dataRepresentation()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Scales an image size to fit within a maximum dimension while preserving aspect ratio
    private func scaledSize(for image: UIImage, maxDimension: CGFloat) -> CGSize {
        let originalSize = image.size
        let scale = min(maxDimension / originalSize.width, maxDimension / originalSize.height)
        return CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
    }

    private func makeCGContext(size: CGSize, scale: CGFloat) -> CGContext? {
        let width = Int(size.width * scale)
        let height = Int(size.height * scale)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space:  colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        return context
    }
}


extension NSAttributedString{
    func centerRect(in rect: CGRect) -> CGRect {
        let textSize = self.size()
        let textCenter = CGPoint(
            x: rect.midX - (textSize.width / 2),
            y: rect.midY - (textSize.height / 2)
        )
        
        return CGRect(origin: textCenter, size: textSize)
    }
}
