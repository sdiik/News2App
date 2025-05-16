//
//  Auth0Config.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Foundation

class Auth0Config {
    static let shared = Auth0Config()

    let clientID: String
    let domain: String

    private init() {
        guard
            let path = Bundle.main.path(forResource: "Auth0", ofType: "plist"),
            let infoDict = NSDictionary(contentsOfFile: path),
            let clientID = infoDict["ClientId"] as? String,
            let domain = infoDict["Domain"] as? String
        else {
            fatalError("Auth0ClientID and Auth0Domain must be set in Info.plist")
        }

        self.clientID = clientID
        self.domain = domain
    }
}
