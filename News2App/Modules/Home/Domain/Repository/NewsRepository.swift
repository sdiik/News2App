//
//  NewsRepository.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

typealias FetchItemsResult = (_ result: Result<NewsResponse, FetchNewsError>) -> Void

protocol NewsRepository {
    func fetchNews(type: NewsType, completion: @escaping FetchItemsResult)
}
