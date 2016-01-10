//
//  UIImageExtensions.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 10-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    /// Download and process an image in the background
    static internal func processImageWithUrl(imageUrl: String?) -> UIImage? {
        // Load the image from the network
        let imageUrl = imageUrl ?? "https://placeholdit.imgix.net/~text?txtsize=42&txt=Geen+afbeelding+beschikbaar&w=1500&h=843&txttrack=0"
        guard let url = NSURL(string: imageUrl.stringByReplacingOccurrencesOfString("http://", withString: "https://")) else { return nil }
        guard let data = NSData(contentsOfURL: url) else { return nil }

        // Load the image.
        guard let image = UIImage(data: data) else { return nil }

        // Create a `CGColorSpace` and `CGBitmapInfo` value that is appropriate for the device.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue

        // Create a bitmap context of the same size as the image.
        let imageWidth = Int(Float(image.size.width))
        let imageHeight = Int(Float(image.size.height))

        let bitmapContext = CGBitmapContextCreate(nil, imageWidth, imageHeight, 8, imageWidth * 4, colorSpace, bitmapInfo)

        // Draw the image into the graphics context.
        guard let imageRef = image.CGImage else { fatalError("Unable to get a CGImage from a UIImage.") }
        CGContextDrawImage(bitmapContext, CGRect(origin: CGPoint.zero, size: image.size), imageRef)

        // Create a new `CGImage` from the contents of the graphics context.
        guard let newImageRef = CGBitmapContextCreateImage(bitmapContext) else { return image }

        // Return a new `UIImage` created from the `CGImage`.
        return UIImage(CGImage: newImageRef)
    }
}