//
//  LiveViewController.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import UIKit
import Argo
import Alamofire
import AlamofireImage
import TVServices

class LiveViewController: UIViewController {
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var livestreamStackView: UIStackView!
    
    var livestreams: [LiveStream] = []
    var livestreamButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadButton.hidden = true

        // Load all the livestreams
        ApiManager.loadLiveStreams { result in
            do {
                try self.processLiveStreamResult(result)
            } catch {
                self.displayLoadingErrorAlert()
            }
        }
    }

    /// Reload the livestreams
    @IBAction func reload(sender: AnyObject) {
        loadingView.hidden = false
        reloadButton.hidden = true

        for button in livestreamButtons {
            button.removeFromSuperview()
        }
        livestreamButtons = []

        ApiManager.loadLiveStreams { result in
            do {
                try self.processLiveStreamResult(result)
            } catch {
                self.displayLoadingErrorAlert()
            }
        }

        if let mainVC = self.parentViewController as? MainTabBarController {
            mainVC.loadLiveStreams()
        }
    }

    /// Process livestream results
    func processLiveStreamResult(result: ApiManager.LiveStreamResult) throws {
        switch result {
        case .Error:
            displayLoadingErrorAlert()
        case .Success(let livestreams):
            self.livestreams = try livestreams.filter { try ApiManager.livelivestreams().contains($0.id) }

            let defaults = NSUserDefaults(suiteName: Constants.AppGroup)
            let livestreamsDictionary = self.livestreams.map { $0.toDictionary() }
            defaults?.setObject(livestreamsDictionary, forKey: Constants.PrefLiveStreams)
            defaults?.synchronize()
            let notification = NSNotification(name: TVTopShelfItemsDidChangeNotification, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)

            self.loadingView.hidden = true
            self.reloadButton.hidden = true

            for livestream in self.livestreams {
                let button = UIButton(type: UIButtonType.System)
                button.setTitle(livestream.title, forState: .Normal)
                button.addTarget(self, action: Selector("livestreamButtonTapped:"), forControlEvents: .PrimaryActionTriggered)
                self.livestreamButtons.append(button)
                self.livestreamStackView.addArrangedSubview(button)
            }

            self.livestreamStackView.layoutIfNeeded()
        }
    }

    /// User tapped a livestream button, play the stream
    func livestreamButtonTapped(sender: UIButton) {
        guard let idx = livestreamButtons.indexOf(sender) else {
            return
        }

        let livestream = livestreams[idx]

        guard let hlsLink = livestream.hlsLink else {
            displayOKAlert("Fout bij afspelen van livestream", message: "Deze livestream kan momenteel niet afgespeeld worden")
            return
        }

        // Try to get the image
        Alamofire.request(.GET, livestream.thumbnail).responseImage { response in
            let image = response.result.value

            self.displayMediaWithURL(hlsLink, title: livestream.title, description: livestream.description, thumbnail: image)
        }
    }

    // Display an alert that loading failed
    private func displayLoadingErrorAlert() {
        let title = "Kan live niet laden"
        let message = "Probeer het a.u.b. opnieuw"
        displayOKAlert(title, message: message) {
            self.loadingView.hidden = true
            self.reloadButton.hidden = false
        }
    }
}

