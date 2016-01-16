//
//  AppDelegate.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Add image/jpg to AlamofireImage because the API returns that instead of image/jpeg
        Alamofire.Request.addAcceptableImageContentTypes(["image/jpg"])

        do {
            try ApiManager.initialize()
        } catch (let e) {
            fatalError("Error initializing API manager: \(e)")
        }

        // Load recent items to show in the top shelf
        ApiManager.loadRecentItems()

        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        // Process links to this app. This can be the following:
        // * s1-demo://details?item=ITEMID: Show details of this item
        // * s1-demo://play?item=ITEMID: Play the item immediately
        // * s1-demo://play?livestream=LIVESTREAMID: Play the livestream immediately

        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var item: String? = nil
        var livestream: String? = nil
        if let components = components {
            if let queryItems = components.queryItems {
                for queryItem in queryItems {
                    if queryItem.name == "livestream" {
                        livestream = queryItem.value
                    } else if queryItem.name == "item" {
                        item = queryItem.value
                    }
                }
            }
        }

        if let livestream = livestream {
            if url.host == "play" {
                ApiManager.loadLiveStreams { result in
                    switch result {
                    case .Success(let livestreams):
                        let foundStreams = livestreams.filter { $0.id == livestream }
                        if let livestream = foundStreams.first {
                            guard let hlsLink = livestream.hlsLink else {
                                return
                            }

                            // Try to get the image
                            Alamofire.request(.GET, livestream.thumbnail).responseImage { response in
                                let image = response.result.value
                                if let vc = self.window?.rootViewController?.frontMostViewController {
                                    vc.displayMediaWithURL(hlsLink, title: livestream.title, description: livestream.description, thumbnail: image)
                                }
                            }
                        }
                    default:
                        // Nothing, livestream fetching failed
                        break
                    }
                }
            }
        } else if let item = item {
            if url.host == "details" {
                if let itemDetailViewController = R.storyboard.main.itemDetailViewController() {
                    itemDetailViewController.itemId = item

                    window?.rootViewController?.frontMostViewController.presentViewController(itemDetailViewController, animated: true, completion: nil)
                }
            } else if url.host == "play" {
                ApiManager.loadItemWithId(item) { result in
                    switch (result) {
                    case .Success(let item):
                        guard let playbackLink = item.playbackLink else { return }

                        guard let vc = self.window?.rootViewController?.frontMostViewController else { return }

                        if let thumbnail = item.thumbnail {
                            // Try to get the image
                            Alamofire.request(.GET, thumbnail).responseImage { response in
                                let image = response.result.value

                                vc.displayMediaWithURL(playbackLink, title: item.title, description: item.description, aired: item.dateAired?.apiDateStringToDate, thumbnail: image)
                            }
                        } else {
                            vc.displayMediaWithURL(playbackLink, title: item.title, description: item.description, aired: item.dateAired?.apiDateStringToDate, thumbnail: nil)
                        }
                    default:
                        // Nothing, item fetching failed
                        break
                    }
                }
            }
            
        }
        
        return false
    }
}

