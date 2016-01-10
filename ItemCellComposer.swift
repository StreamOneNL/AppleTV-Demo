//
//  ItemCellComposer.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 10-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//
//  Based of example code from Apple
//

import UIKit

class ItemCellComposer {
    // MARK: Properties

    /// Cache used to store processed images, keyed on `Item` identifiers.
    static private var processedImageCache = NSCache()

    /**
     A dictionary of `NSOperationQueue`s for `ItemCollectionViewCell`s. The
     queues contain operations that process images for `Item`s before updating
     the cell's `UIImageView`.
     */
    private var operationQueues = [ItemCell: NSOperationQueue]()

    // MARK: Implementation

    func composeCell(cell: ItemCell, withItem item: Item) {
        // Cancel any queued operations to process images for the cell.
        let operationQueue = operationQueueForCell(cell)
        operationQueue.cancelAllOperations()

        // Set the cell's properties.
        cell.representedItem = item
        cell.titleLabel.text = item.title
        cell.dateLabel.text = item.dateAired?.displayDate
        cell.durationLabel.text = item.duration
        cell.imageView.alpha = 1.0
        cell.imageView.image = ItemCellComposer.processedImageCache.objectForKey(item.id) as? UIImage

        // No further work is necessary if the cell's image view has an image.
        guard cell.imageView.image == nil else { return }

        /*
        Initial rendering of a jpeg image can be expensive. To avoid stalling
        the main thread, we create an operation to process the `DataItem`'s
        image before updating the cell's image view.

        The execution block is added after the operation is created to allow
        the block to check if the operation has been cancelled.
        */
        let processImageOperation = NSBlockOperation()

        processImageOperation.addExecutionBlock { [unowned processImageOperation] in
            // Ensure the operation has not been cancelled.
            guard !processImageOperation.cancelled else { return }

            // Load and process the image.
            guard let image = self.processImageWithUrl(item.thumbnail) else { return }

            // Store the processed image in the cache.
            ItemCellComposer.processedImageCache.setObject(image, forKey: item.id)

            NSOperationQueue.mainQueue().addOperationWithBlock {
                // Check that the cell is still showing the same `Item`.
                guard item == cell.representedItem else { return }

                // Update the cell's `UIImageView` and then fade it into view.
                cell.imageView.alpha = 0.0
                cell.imageView.image = image

                UIView.animateWithDuration(0.25) {
                    cell.imageView.alpha = 1.0
                }
            }
        }

        operationQueue.addOperation(processImageOperation)
    }

    // MARK: Convenience

    /**
    Returns the `NSOperationQueue` for a given cell. Creates and stores a new
    queue if one doesn't already exist.
    */
    private func operationQueueForCell(cell: ItemCell) -> NSOperationQueue {
        if let queue = operationQueues[cell] {
            return queue
        }

        let queue = NSOperationQueue()
        operationQueues[cell] = queue

        return queue
    }

    /**
     Loads a UIImage for a given name and returns a version that has been drawn
     into a `CGBitmapContext`.
     */
    private func processImageWithUrl(imageUrl: String?) -> UIImage? {
        // Load the image from the network
        let imageUrl = imageUrl ?? "https://placeholdit.imgix.net/~text?txtsize=42&txt=No+image+available&w=1000&h=560&txttrack=0"
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
