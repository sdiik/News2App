//
//  LoginRepository.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Auth0

typealias loginResult = (Result<Credentials, Error>) -> Void

protocol LoginRepository {
    func login(email: String, password: String, result: @escaping loginResult)
}
