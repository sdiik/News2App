//
//  LoginError.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

enum LoginError: Error {
    case invalidCredentials
    case serverError(String)
}
