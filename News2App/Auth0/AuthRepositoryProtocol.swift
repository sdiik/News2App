//
//  AuthRepositoryProtocol.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Foundation
import Auth0

protocol AuthRepositoryProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void)
    func register(email: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void)
}
