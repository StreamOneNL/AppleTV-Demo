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
    let description: String?
    let duration: String
    let dateCreated: String?
    let dateAired: String?
    let views: Int
    let thumbnail: String?
    let hlsLink: String?
    let account: BasicAccount
}

extension Item: Decodable {
    static func decode(json: JSON) -> Decoded<Item> {
        let i = curry(Item.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <|? "description"
            <*> json <| "duration"
        return i
            <*> json <|? "datecreated"
            <*> json <|? "dateaired"
            <*> json <| "views"
            <*> json <|? "selectedthumbnailurl"
            <*> json <|? ["medialink", "hls"]
            <*> json <| "account"
    }
}

extension Item : Equatable {}

func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.id == rhs.id
}