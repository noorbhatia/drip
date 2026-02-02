//
//  BackgroundRemover.swift
//  drip
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Vision

/// Utility for removing backgrounds from clothing photos using Apple's Vision framework.
/// Uses VNGenerateForegroundInstanceMaskRequest to detect and isolate foreground subjects.
@MainActor
final class BackgroundRemover {

    enum BackgroundRemovalError: LocalizedError {
        case failedToCreateCIImage
        case failedToGenerateMask
        case failedToApplyMask
        case failedToCreateOutputImage

        var errorDescription: String? {
            switch self {
            case .failedToCreateCIImage:
                return "Failed to create image from data"
            case .failedToGenerateMask:
                return "Failed to generate foreground mask"
            case .failedToApplyMask:
                return "Failed to apply mask to image"
            case .failedToCreateOutputImage:
                return "Failed to create output image"
            }
        }
    }

    /// Removes the background from an image, returning the subject with a transparent background.
    /// - Parameter imageData: The original image data (JPEG, PNG, HEIC, etc.)
    /// - Returns: PNG data with transparent background
    /// - Note: This method requires a physical device; Vision ML models don't run on Simulator.
    static func removeBackground(from imageData: Data) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try processImage(imageData)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private nonisolated static func processImage(_ imageData: Data) throws -> Data {
        guard let uiImage = UIImage(data: imageData),
            let ciImage = CIImage(image: uiImage)
        else {
            throw BackgroundRemovalError.failedToCreateCIImage
        }

        // Capture original orientation before processing
        let orientation = uiImage.imageOrientation

        // Apply orientation to CIImage to ensure Vision processes correctly oriented image
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(orientation.cgImagePropertyOrientation))

        // Generate masked image (pixels are now upright)
        let maskedImage = try createMaskedImage(from: orientedImage)

        // Convert to PNG data with .up orientation (pixels already upright, no metadata rotation needed)
        return try convertToData(maskedImage)
    }

    private nonisolated static func createMaskedImage(from inputImage: CIImage) throws -> CIImage {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: inputImage)

        try handler.perform([request])

        guard let result = request.results?.first else {
            throw BackgroundRemovalError.failedToGenerateMask
        }

        let maskedPixelBuffer = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: false  // Keep original dimensions
        )

        return CIImage(cvPixelBuffer: maskedPixelBuffer)
    }

    private nonisolated static func convertToData(_ ciImage: CIImage) throws -> Data {
        let context = CIContext(options: [.useSoftwareRenderer: false])

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw BackgroundRemovalError.failedToCreateOutputImage
        }

        // Create UIImage with .up orientation (pixels are already correctly rotated)
        let uiImage = UIImage(cgImage: cgImage)

        guard let pngData = uiImage.pngData() else {
            throw BackgroundRemovalError.failedToCreateOutputImage
        }

        return pngData
    }
}

private extension UIImage.Orientation {
    /// Maps UIImage.Orientation to EXIF orientation values used by CIImage.
    nonisolated var cgImagePropertyOrientation: Int32 {
        switch self {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }
}
