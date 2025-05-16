//
//  RegisterUseCase.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Auth0

typealias RegisterUseCaseResult = (Result<Credentials, Error>) -> Void

protocol RegisterUseCase {
    func register(email: String, password: String, result: @escaping RegisterUseCaseResult)
}
