//
//  LoginUseCase.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Auth0

typealias loginUseCaseResult = (Result<Credentials, Error>) -> Void

protocol LoginUseCase {
    func login(email: String, password: String, result: @escaping loginResult)
}
