//
//  LiveStreamType.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

struct LiveStreamType {
    let label: String
    let name: String
}

extension LiveStreamType: Decodable {
    static func decode(json: JSON) -> Decoded<LiveStreamType> {
        return curry(LiveStreamType.init)
            <^> json <| "label"
            <*> json <| "name"
    }
}