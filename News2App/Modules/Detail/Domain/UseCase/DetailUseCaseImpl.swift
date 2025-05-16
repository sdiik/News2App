//
//  DetailUseCaseImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

class DetailUseCaseImpl: DetailUseCase {
    let detailRepository: DetailRepository
    
    init(detailRepository: DetailRepository = DetailRepositoryImpl()) {
        self.detailRepository = detailRepository
    }
    
    func execute(with id: Int, detailType: DetailType, completionHandler: @escaping DetailUseCaseCompletionHandler) {
        detailRepository.detailNews(with: id, detailType: detailType) { result in
            switch result {
            case .success(let newsResponse):
                completionHandler(.success(newsResponse))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
