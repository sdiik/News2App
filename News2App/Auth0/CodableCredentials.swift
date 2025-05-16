//
//  CodableCredentials.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Auth0
import Foundation

struct CodableCredentials: Codable {
    let accessToken: String?
    let idToken: String?
    let expiresIn: Date?

    init(credentials: Credentials) {
        accessToken = credentials.accessToken
        idToken = credentials.idToken
        expiresIn = credentials.expiresIn
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
