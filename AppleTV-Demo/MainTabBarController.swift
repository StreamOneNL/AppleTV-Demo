//
//  MainTabBarController.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    var livestreams: [LiveStream] = []
    var alllivestreams: [LiveStream] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadLiveStreams()
    }

    private func loadLiveStreams() {
        livestreams = []
        alllivestreams = []
        loadLiveStreamsFrom(0)
    }

    private func loadLiveStreamsFrom(idx: Int) {
        do {
            let livestreamsToDisplay = try ApiManager.gemiststreams()
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

                    for livestream in livestreams {
                        self.alllivestreams.append(livestream)
                        if !livestreamsToDisplay.contains(livestream.id) {
                            continue
                        }
                        self.livestreams.append(livestream)

                        if let vc = R.storyboard.main.itemsViewController() {
                            vc.livestream = livestream
                            vc.tabBarItem.title = "Gemist voor \(livestream.title)"

                            self.viewControllers?.append(vc)
                        }
                    }

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
        }
    }
}
