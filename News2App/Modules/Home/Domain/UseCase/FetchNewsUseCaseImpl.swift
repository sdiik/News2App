//
//  FetchNewsUseCaseImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

class FetchNewsUseCaseImpl: FetchNewsUseCase {
    let newsRepository: NewsRepository
    
    init(newsRepository: NewsRepository = NewsRepositoryImpl()) {
        self.newsRepository = newsRepository
    }
    
    func execute(type: NewsType, completionHandler: @escaping FetchNewsUseCaseCompletionHandler) {
        newsRepository.fetchNews(type: type) { result in
            switch result {
            case .success(let newsResponse):
                completionHandler(.success(newsResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
