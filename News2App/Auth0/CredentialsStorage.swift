//
//  CredentialsStorage.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Auth0
import Foundation
import KeychainSwift

final class CredentialsStorage {
    private let key = "userCredentials"
    private let timestampKey = "loginTimestamp"
    
    private let keychain = KeychainSwift()
    private let sessionTimeout: TimeInterval = 60

    func save(_ credentials: Credentials) {
        let codable = CodableCredentials(credentials: credentials)
        if let data = try? JSONEncoder().encode(codable) {
            keychain.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: timestampKey)
        }
    }
    
    func load() -> CodableCredentials? {
        guard let data = keychain.getData(key),
              let credentials = try? JSONDecoder().decode(CodableCredentials.self, from: data) else {
            return nil
        }
        return credentials
    }
    
    func isExpired() -> Bool {
        guard let loginTime = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return true
        }
        let elapsed = Date().timeIntervalSince(loginTime)
        return elapsed > sessionTimeout
    }
    
    func getUsername() -> String {
        let data = load()
        if let idToken = data?.idToken {
            let userInfo = decode(jwtToken: idToken)
            return "\(userInfo["nickname"] ?? "N/A")"
        } else {
            return ""
        }
    }
    
    func clear() {
        keychain.delete(key)
        UserDefaults.standard.removeObject(forKey: timestampKey)
    }
}
