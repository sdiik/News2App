//
//  CodableCredentials.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Foundation
import Auth0

struct CodableCredentials: Codable {
    let accessToken: String?
    let idToken: String?
    let expiresIn: Date?
    
    init(credentials: Credentials) {
        self.accessToken = credentials.accessToken
        self.idToken = credentials.idToken
        self.expiresIn = credentials.expiresIn
    }
    
    func toCredentials() -> Credentials {
        return Credentials(
            accessToken: accessToken ?? "",
            tokenType: "",
            idToken: idToken ?? "",
            refreshToken: nil,
            expiresIn: expiresIn ?? Date(),
            scope: nil
        )
    }
}
