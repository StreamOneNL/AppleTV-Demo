//
//  ServiceProvider.swift
//  Top Shelf Extension
//
//  Created by Nicky Gerritsen on 16-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import Foundation
import TVServices
import Argo

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        return .Sectioned
    }

    var topShelfItems: [TVContentItem] {
        // Add livestreams
        let item = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: "livesterams", container: nil)!)!
        item.title = "Kijk live"

        let defaults = NSUserDefaults(suiteName: Constants.AppGroup)

        if let livestreamData = defaults?.objectForKey(Constants.PrefLiveStreams) {
            var topShelfItems: [TVContentItem] = []
            print(livestreamData)
            let livestreams: [LiveStream]? = decode(livestreamData)
            if let livestreams = livestreams {
                for livestream in livestreams {
                    let topShelfItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: livestream.id, container: nil)!)!
                    topShelfItem.title = livestream.title
                    topShelfItem.imageURL = NSURL(string: livestream.thumbnail ?? "https://placeholdit.imgix.net/~text?txtsize=42&txt=Geen+afbeelding+beschikbaar&w=1000&h=560&txttrack=0")
                    if livestream.type.label != "new-wowza-livestream" {
                        topShelfItem.imageURL = NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=42&txt=Radio&w=1000&h=560&txttrack=0")
                    }
                    topShelfItem.imageShape = TVContentItemImageShape.HDTV
                    topShelfItem.displayURL = NSURL(string: "\(Constants.UrlScheme)://play?livestream=\(livestream.id)")
                    topShelfItem.playURL = NSURL(string: "\(Constants.UrlScheme)://play?livestream=\(livestream.id)")

                    topShelfItems.append(topShelfItem)
                }
            }
            item.topShelfItems = topShelfItems
        }

        // Add recent items
        let itemsItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: "lastitems", container: nil)!)!
        itemsItem.title = "Kijk terug"

        if let itemsData = defaults?.objectForKey(Constants.PrefLastItems) {
            var topShelfItems: [TVContentItem] = []
            print(itemsData)
            let items: [Item]? = decode(itemsData)
            if let items = items {
                for lastItem in items {
                    let topShelfItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: lastItem.id, container: nil)!)!
                    topShelfItem.title = lastItem.title
                    topShelfItem.imageURL = NSURL(string: lastItem.thumbnail ?? "https://placeholdit.imgix.net/~text?txtsize=42&txt=Geen+afbeelding+beschikbaar&w=1000&h=560&txttrack=0")
                    topShelfItem.imageShape = TVContentItemImageShape.HDTV
                    topShelfItem.displayURL = NSURL(string: "\(Constants.UrlScheme)://details?item=\(lastItem.id)")
                    topShelfItem.playURL = NSURL(string: "\(Constants.UrlScheme)://play?item=\(lastItem.id)")

                    topShelfItems.append(topShelfItem)
                }
            }
            itemsItem.topShelfItems = topShelfItems
        }

        return [item, itemsItem]
    }

}

