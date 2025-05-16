//
//  RegisterError.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

enum RegisterError: Error {
    case invalidCredentials
    case serverError(String)
}
