//
//  URLSessionProtocol.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
