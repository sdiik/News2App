//
//  RegisterRepository.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Auth0

typealias registerResult = (Result<Credentials, Error>) -> Void

protocol RegisterRepository {
    func register(email: String, password: String, result: @escaping registerResult)
}
