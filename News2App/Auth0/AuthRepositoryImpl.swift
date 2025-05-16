//
//  AuthRepositoryImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Auth0
import Foundation

struct AuthRepositoryImpl: AuthRepositoryProtocol {
    private let auth: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        auth = authService
    }

    func login(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void) {
        auth.login(email: email, password: password, completion: completion)
    }

    func register(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void) {
        auth.register(email: email, password: password, completion: completion)
    }
}
