//
//  ItemType.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 10-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import Foundation
import Argo

enum ItemType: Decodable {
    case Video
    case Audio
    case VideoOnly

    static func decode(json: JSON) -> Decoded<ItemType> {
        switch json {
        case .String(let s):
            switch s {
            case "video": return pure(.Video)
            case "audio": return pure(.Audio)
            case "videoonly": return pure(.VideoOnly)
            default: return .typeMismatch("Item type", actual: s)
            }
        default: return .typeMismatch("String", actual: json)
        }
    }

    var stringValue: String {
        switch self {
        case .Video: return "video"
        case .Audio: return "audio"
        case .VideoOnly: return "videoonly"
        }
    }
}