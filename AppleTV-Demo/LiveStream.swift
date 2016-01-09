//
//  LiveStream.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry
import StreamOneSDK

struct LiveStream {
    let id: String
    let title: String
    let description: String?
    let type: LiveStreamType
    let thumbnail: String
    let hlsLink: String?
    let account: BasicAccount
}

extension LiveStream: Decodable {
    static func decode(json: JSON) -> Decoded<LiveStream> {
        let i = curry(LiveStream.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <|? "description"
            <*> json <| "type"
        return i
            <*> json <| "thumbnail"
            <*> json <|? ["medialink", "hls"]
            <*> json <| "account"
    }
}