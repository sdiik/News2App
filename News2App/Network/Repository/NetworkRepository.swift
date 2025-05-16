//
//  NetworkRepository.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Foundation

typealias FetchRequestResult = (_ result: Result<(HTTPURLResponse, Any), Error>) -> Void

protocol NetworkRepository {
    func fetchRequest(_ url: URL, result: @escaping FetchRequestResult)
}
