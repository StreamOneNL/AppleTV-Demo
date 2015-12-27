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

class LiveViewController: UIViewController {
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var livestreamStackView: UIStackView!
    
    var livestreams: [LiveStream] = []
    var alllivestreams: [LiveStream] = []
    var livestreamButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadButton.hidden = true

        loadLiveStreams()
    }

    @IBAction func reload(sender: AnyObject) {
        loadingView.hidden = false
        reloadButton.hidden = true
        loadLiveStreams()
    }

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

    private func loadLiveStreams() {
        livestreams = []
        alllivestreams = []
        for button in livestreamButtons {
            livestreamStackView.removeArrangedSubview(button)
        }
        livestreamButtons = []
        loadLiveStreamsFrom(0)
    }

    private func loadLiveStreamsFrom(idx: Int) {
        do {
            let livestreamsToDisplay = try ApiManager.livestreams()
            let request = try ApiManager.newRequest(command: "livestream", action: "view")
            request
                .setArgument("active", value: true)
                .setArgument("orderfield", value: "name")
                .execute { response in
                    guard response.success else {
                        self.displayLoadingErrorAlert()
                        return
                    }

                    guard let livestreams: [LiveStream] = response.typedBody() else {
                        self.displayLoadingErrorAlert()
                        return
                    }

                    guard let count = response.header.allFields["count"] as? Int else {
                        self.displayLoadingErrorAlert()
                        return
                    }

                    self.loadingView.hidden = true

                    for livestream in livestreams {
                        self.alllivestreams.append(livestream)
                        if !livestreamsToDisplay.contains(livestream.id) {
                            continue
                        }
                        self.livestreams.append(livestream)
                        let button = UIButton(type: UIButtonType.System)
                        button.setTitle(livestream.title, forState: .Normal)
                        button.addTarget(self, action: Selector("livestreamButtonTapped:"), forControlEvents: .PrimaryActionTriggered)
                        self.livestreamButtons.append(button)
                        self.livestreamStackView.addArrangedSubview(button)
                    }

                    self.livestreamStackView.layoutIfNeeded()

                    if count > self.alllivestreams.count {
                        self.loadLiveStreamsFrom(self.alllivestreams.count)
                    }
            }
        } catch (_) {
            displayLoadingErrorAlert()
        }
    }

    private func displayLoadingErrorAlert() {
        let title = "Kan live niet laden"
        let message = "Probeer het a.u.b. opnieuw"
        displayOKAlert(title, message: message) {
            self.loadingView.hidden = true
            self.reloadButton.hidden = false
        }
    }
}

