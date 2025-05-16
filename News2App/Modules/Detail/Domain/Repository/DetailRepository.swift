//
//  DetailRepository.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

import Foundation

typealias DetailItemResult = (_ result: Result<Blog, DetailError>) -> Void

protocol DetailRepository {
    func detailNews(with id: Int, detailType: DetailType, completion: @escaping DetailItemResult)
}
