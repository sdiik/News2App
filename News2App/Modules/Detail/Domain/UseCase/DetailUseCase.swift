//
//  DetailUseCase.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

import Foundation

typealias DetailUseCaseCompletionHandler = (_ result: Result<Blog, DetailError>) -> Void

protocol DetailUseCase {
    func execute(with id: Int, detailType: DetailType, completionHandler: @escaping DetailUseCaseCompletionHandler)
}
