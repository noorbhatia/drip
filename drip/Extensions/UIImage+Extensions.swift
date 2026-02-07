//
//  UIImage+Extensions.swift
//  drip
//
//  Created by Noor Bhatia on 26/01/26.
//

import Foundation

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    var averageColor: UIColor? {
        let filter = CIFilter.areaAverage()
        let inputImage = CIImage(image: self)
        filter.inputImage = inputImage
        filter.extent = inputImage?.extent ?? .zero

        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: nil)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    /// Extracts dominant colors from the image for gradient backgrounds
    func extractDominantColors(count: Int = 2) -> [UIColor] {
        guard let inputImage = CIImage(image: self) else {
            return [.gray, .gray.withAlphaComponent(0.5)]
        }
        
        // Use area average for a quick dominant color
        let filter = CIFilter.areaAverage()
        filter.inputImage = inputImage
        filter.extent = inputImage.extent
        
        guard let outputImage = filter.outputImage else {
            return [.gray, .gray.withAlphaComponent(0.5)]
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: nil)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let dominantColor = UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1.0
        )
        
        // Create complementary colors for gradient
        let darkerColor = dominantColor.adjustBrightness(by: -0.2)
        let lighterColor = dominantColor.adjustBrightness(by: 0.1)
        
        return [darkerColor, lighterColor]
    }
}

extension UIColor {
    /// Adjusts the brightness of a color
    func adjustBrightness(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = max(0, min(1, brightness + percentage))
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }
        
        return self
    }
}
