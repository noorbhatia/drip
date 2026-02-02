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
}
