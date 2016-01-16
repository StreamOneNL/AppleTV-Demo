//
//  Item.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 09-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry
import StreamOneSDK

struct Item {
    let id: String
    let title: String
    let type: ItemType
    let description: String?
    let duration: String
    let dateCreated: String?
    let dateAired: String?
    let views: Int
    let thumbnail: String?
    let progressiveLink: String?
    let hlsLink: String?
    let account: BasicAccount

    var playbackLink: String? {
        return hlsLink ?? progressiveLink
    }
}

extension Item: Decodable {
    static func decode(json: JSON) -> Decoded<Item> {
        let i = curry(Item.init)
        return i
            <^> json <| "id"
            <*> json <| "title"
            <*> json <| "type"
            <*> json <|? "description"
            <*> json <| "duration"
            <*> json <|? "datecreated"
            <*> json <|? "dateaired"
            <*> json <| "views"
            <*> json <|? "selectedthumbnailurl"
            <*> json <|? ["medialink", "progressive"]
            <*> json <|? ["medialink", "hls"]
            <*> json <| "account"
    }
}

extension Item {


    func toDictionary() -> [String: AnyObject] {
        var result: [String: AnyObject] = [:]

        result["id"] = id
        result["title"] = title
        result["type"] = type.stringValue
        result["description"] = description
        result["duration"] = duration
        result["datecreated"] = dateCreated
        result["dateaired"] = dateAired
        result["views"] = views
        result["selectedthumbnailurl"] = thumbnail
        var medialinks: [String: String] = [:]
        if let hlsLink = hlsLink {
            medialinks["hls"] = hlsLink
        }
        if let progressiveLink = progressiveLink {
            medialinks["progressive"] = progressiveLink
        }
        result["medialink"] = medialinks
        result["account"] = ["id": account.id, "name": account.name]

        return result
    }
}

extension Item : Equatable {}

func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.id == rhs.id
}