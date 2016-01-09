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

    override func viewDidLoad() {
        super.viewDidLoad()

        loadLiveStreams()
    }

    func loadLiveStreams() {
        guard let firstVc = self.viewControllers?[0] else {
            return
        }

        self.viewControllers = [firstVc]

        ApiManager.loadLiveStreams { result in
            switch result {
            case .Error:
                self.displayLoadingErrorAlert()
            case .Success(let livestreams):
                do {
                    self.livestreams = try livestreams.filter { try ApiManager.gemiststreams().contains($0.id) }

                    for livestream in self.livestreams {
                        if let vc = R.storyboard.main.itemsViewController() {
                            vc.livestream = livestream
                            vc.tabBarItem.title = "Gemist voor \(livestream.title)"

                            self.viewControllers?.append(vc)
                        }
                    }
                } catch {
                    self.displayLoadingErrorAlert()
                }
            }
        }
    }

    private func displayLoadingErrorAlert() {
        let title = "Kan live niet laden"
        let message = "Probeer het a.u.b. opnieuw"
        displayOKAlert(title, message: message)
    }
}
