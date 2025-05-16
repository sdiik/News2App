//
//  FetchNewsUseCase.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

typealias FetchNewsUseCaseCompletionHandler = (_ result: Result<NewsResponse, FetchNewsError>) -> Void

protocol FetchNewsUseCase {
    func execute(type: NewsType, completionHandler: @escaping FetchNewsUseCaseCompletionHandler)
}
