//
//  UIImageExtension.swift
//  Macro
//
//  Created by WanSen on 17/10/24.
//


import UIKit
import CoreML

extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {
           UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
           defer { UIGraphicsEndImageContext() }
           self.draw(in: CGRect(origin: .zero, size: size))
           return UIGraphicsGetImageFromCurrentImageContext()
       }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        guard let cgImage = self.cgImage, let cgContext = context else {
            return nil
        }

        cgContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}

