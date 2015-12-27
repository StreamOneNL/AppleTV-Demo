//
//  Platform.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import StreamOneSDK
import Argo
import Curry

private struct ApiSettings {
    let apiUrl: String
    let useApplicationAuth: Bool
    let applicationId: String?
    let applicationPSK: String?
    let userId: String?
    let userPSK: String?
    let account: String
}

extension ApiSettings : Decodable {
    static func decode(dict: JSON) -> Decoded<ApiSettings> {
        let i = curry(ApiSettings.init)
            <^> dict <| "apiUrl"
            <*> dict <| "useApplicationAuth"
            <*> dict <|? "applicationId"
            <*> dict <|? "applicationPSK"

        return i
            <*> dict <|? "userId"
            <*> dict <|? "userPSK"
            <*> dict <| "account"
    }
}

class ApiManager {
    enum Error: ErrorType {
        case NoSuchFile
        case CanNotParsePlist
        case InvalidPlist(DecodeError)
        case MissingSettings(String)
        case NotInitialized
    }

    private static let sharedManager = ApiManager()
    private var actor: Actor?

    static func initialize() throws {
        let bundle = NSBundle(forClass: self)
        guard let plist = bundle.pathForResource("ApiSettings", ofType: "plist") else {
            throw ApiManager.Error.NoSuchFile
        }

        guard let plistDict = NSDictionary(contentsOfFile: plist) else {
            throw ApiManager.Error.CanNotParsePlist
        }

        let apiSettings: Decoded<ApiSettings> = decode(plistDict)
        guard let settings = apiSettings.value else {
            throw ApiManager.Error.InvalidPlist(apiSettings.error!)
        }

        let authType: AuthenticationType
        if settings.useApplicationAuth {
            guard let applicationId = settings.applicationId, applicationPSK = settings.applicationPSK else {
                throw ApiManager.Error.MissingSettings("Application authentication is on, but application ID or PSK missing")
            }
            authType = .Application(id: applicationId, psk: applicationPSK)
        } else {
            guard let userId = settings.userId, userPSK = settings.userPSK else {
                throw ApiManager.Error.MissingSettings("Application authentication is off, but user ID or PSK missing")
            }
            authType = .User(id: userId, psk: userPSK)
        }

        var config = Config(authenticationType: authType)
        config.apiUrl = settings.apiUrl

        let platform = Platform(config: config)
        let actor = platform.newActor()
        actor.accounts = [settings.account]
        sharedManager.actor = actor
    }

    static func newRequest(command command: String, action: String) throws -> Request {
        guard let actor = sharedManager.actor else {
            throw ApiManager.Error.NotInitialized
        }
        return try actor.newRequest(command: command, action: action)
    }
}

extension ApiManager.Error : CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .NoSuchFile: return "No such file"
        case .CanNotParsePlist: return "Can not parse plist"
        case .InvalidPlist(let error): return "Invalid plist: \(error)"
        case .MissingSettings(let message): return "Missing values: \(message)"
        case .NotInitialized: return "The API manager is not initialized yet! Call `ApiManager.initialize()` first"
        }
    }
}