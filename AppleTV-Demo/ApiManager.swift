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

/**
    Singleton class used to communicate with the StreamOne SDK

    Always call ApiManager.initialize() in `AppDelegate.application(_:didFinishLaunchingWithOptions:)
*/
class ApiManager {
    /**
        Errors the API manager can return
     */
    enum Error: ErrorType {
        case NoSuchFile
        case CanNotParsePlist
        case InvalidPlist(DecodeError)
        case MissingSettings(String)
        case NotInitialized
    }

    /**
        Struct to hold all settings parsed from the PList file
    */
    private struct Settings {
        let apiUrl: String
        let useApplicationAuth: Bool
        let applicationId: String?
        let applicationPSK: String?
        let userId: String?
        let userPSK: String?
        let account: String
        let livestreams: [String]
        let gemiststreams: [String]
    }

    /**
        The shared API manager instance
    */
    private static let sharedManager = ApiManager()

    private var settings: Settings?

    /**
        The actor used for this manager. Contains a value as soon as `initialize` has been called
    */
    private var actor: Actor?

    /**
        Initialize the API manager
    */
    static func initialize() throws {
        let bundle = NSBundle(forClass: self)
        guard let plist = bundle.pathForResource("ApiSettings", ofType: "plist") else {
            throw ApiManager.Error.NoSuchFile
        }

        guard let plistDict = NSDictionary(contentsOfFile: plist) else {
            throw ApiManager.Error.CanNotParsePlist
        }

        let apiSettings: Decoded<ApiManager.Settings> = decode(plistDict)
        guard let settings = apiSettings.value else {
            throw ApiManager.Error.InvalidPlist(apiSettings.error!)
        }

        sharedManager.settings = settings

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

    /**
        Create a new request for the actor for this API manager
    */
    static func newRequest(command command: String, action: String) throws -> Request {
        guard let actor = sharedManager.actor else {
            throw ApiManager.Error.NotInitialized
        }
        return try actor.newRequest(command: command, action: action)
    }

    static func livestreams() throws -> [String] {
        guard let settings = sharedManager.settings else {
            throw ApiManager.Error.NotInitialized
        }

        return settings.livestreams
    }

    static func gemiststreams() throws -> [String] {
        guard let settings = sharedManager.settings else {
            throw ApiManager.Error.NotInitialized
        }

        return settings.gemiststreams
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

extension ApiManager.Settings : Decodable {
    static func decode(dict: JSON) -> Decoded<ApiManager.Settings> {
        let i = curry(ApiManager.Settings.init)
            <^> dict <| "apiUrl"
            <*> dict <| "useApplicationAuth"
            <*> dict <|? "applicationId"
            <*> dict <|? "applicationPSK"

        return i
            <*> dict <|? "userId"
            <*> dict <|? "userPSK"
            <*> dict <| "account"
            <*> dict <|| "livestreams"
            <*> dict <|| "gemiststreams"
    }
}