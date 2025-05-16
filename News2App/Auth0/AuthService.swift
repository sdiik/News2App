//
//  AuthService.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Auth0

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void)
    func register(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void)
}

class AuthService: AuthServiceProtocol {
    private let clientID = Auth0Config.shared.clientID
    private let domain = Auth0Config.shared.domain
    
    func login(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void) {
        Auth0
            .authentication(clientId: clientID, domain: domain)
            .login(
                usernameOrEmail: email,
                password: password,
                realmOrConnection: "Username-Password-Authentication",
                scope: "openid profile email"
            )
            .start { result in
                switch result {
                case .success(let credentials):
                    completion(.success(credentials))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func register(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void) {
        Auth0
            .authentication(clientId: clientID, domain: domain)
            .signup(
                email: email,
                password: password,
                connection: "Username-Password-Authentication"
            )
            .start { result in
                switch result {
                case .success:
                    self.login(email: email, password: password, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
