//
//  ItemDetailViewController.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 10-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import AlamofireImage

class ItemDetailViewController: UIViewController {
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var thumbImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var airedLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var playButton: UIButton!

    var item: Item?
    var itemId: String?
    var accountId: String?

    let queue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setupView()
    }

    /**
        Set up the view for a given item
    */
    func setupView() {
        // If this view does not have an item yet, it was called directly from the shelf extension
        // Then we need to load the item
        guard let item = item else {
            loadItemAndSetup()
            return
        }

        titleLabel.text = item.title
        descriptionLabel.text = item.description ?? ""
        durationLabel.text = item.duration ?? ""
        airedLabel.text = item.dateAired?.displayDate ?? ""
        playButton.hidden = item.playbackLink == nil

        let processImageOperation = NSBlockOperation()

        processImageOperation.addExecutionBlock { [unowned processImageOperation] in
            // Ensure the operation has not been cancelled.
            guard !processImageOperation.cancelled else { return }

            // Load and process the image.
            guard let image = UIImage.processImageWithUrl(item.thumbnail) else { return }

            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                self?.thumbImageView.alpha = 0.0
                self?.thumbImageView.image = image
                self?.backgroundImageView.image = image

                UIView.animateWithDuration(0.25) {
                    self?.thumbImageView.alpha = 1.0
                }
            }
        }

        queue.addOperation(processImageOperation)
    }

    func loadItemAndSetup() {
        do {
            let request = try ApiManager.newRequest(command: "item", action: "view")
            request.account = accountId
            request.setArgument("item", value: itemId)
            request.execute { [weak self] response in
                if response.valid {
                    if let items: [Item] = response.typedBody() {
                        if items.count == 1 {
                            self?.item = items[0]
                            self?.setupView()
                        }
                    }
                }
            }
        } catch {
            // Nothing for now
        }
    }

    // Play the item if the user taps the play button
    @IBAction func play(sender: AnyObject) {
        guard let item = item else { return }
        guard let playbackLink = item.playbackLink else { return }

        if let thumbnail = item.thumbnail {
            // Try to get the image
            Alamofire.request(.GET, thumbnail).responseImage { response in
                let image = response.result.value

                self.displayMediaWithURL(playbackLink, title: item.title, description: item.description, aired: item.dateAired?.apiDateStringToDate, thumbnail: image)
            }
        } else {
            self.displayMediaWithURL(playbackLink, title: item.title, description: item.description, aired: item.dateAired?.apiDateStringToDate, thumbnail: nil)
        }
    }

    // Process an image
}

