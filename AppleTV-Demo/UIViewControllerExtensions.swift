//
//  UIViewControllerExtensions.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

extension UIViewController {
    /// Display an alert
    func displayAlert(title: String?, message: String?, actions: [UIAlertAction], completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            alert.addAction(action)
        }

        presentViewController(alert, animated: true, completion: completion)
    }

    /// Display an alert with only an OK button
    func displayOKAlert(title: String?, message: String?, completion: (() -> ())? = nil) {
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        displayAlert(title, message: message, actions: [action], completion: completion)
    }

    /// Show a media player for the given url, title, description and thumbnail
    func displayMediaWithURL(url: String, title: String?, description: String?, aired: NSDate? = nil, thumbnail: UIImage?) {
        guard let url = NSURL(string: url) else {
            return
        }

        let item = AVPlayerItem(URL: url)

        if let title = title {
            let metadata = AVMutableMetadataItem()
            metadata.locale = NSLocale.currentLocale()
            metadata.keySpace = AVMetadataKeySpaceCommon
            metadata.key = AVMetadataCommonKeyTitle
            metadata.value = title

            item.externalMetadata.append(metadata)
        }

        if let description = description {
            let metadata = AVMutableMetadataItem()
            metadata.locale = NSLocale.currentLocale()
            metadata.keySpace = AVMetadataKeySpaceCommon
            metadata.key = AVMetadataCommonKeyDescription
            metadata.value = description

            item.externalMetadata.append(metadata)
        }

        if let thumbnail = thumbnail {
            let metadata = AVMutableMetadataItem()
            metadata.locale = NSLocale.currentLocale()
            metadata.keySpace = AVMetadataKeySpaceCommon
            metadata.key = AVMetadataCommonKeyArtwork
            metadata.value = UIImagePNGRepresentation(thumbnail)

            item.externalMetadata.append(metadata)
        }

        if let aired = aired {
            let metadata = AVMutableMetadataItem()
            metadata.locale = NSLocale.currentLocale()
            metadata.keySpace = AVMetadataKeySpaceCommon
            metadata.key = AVMetadataCommonKeyCreationDate
            metadata.value = aired

            item.externalMetadata.append(metadata)
        }

        let player = AVPlayer(playerItem: item)

        let playerVC = AVPlayerViewController()
        playerVC.player = player

        presentViewController(playerVC, animated: true) {
            player.play()
        }
    }
}