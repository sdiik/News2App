//
//  DetailRepositoryImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

import Foundation

class DetailRepositoryImpl: DetailRepository {
    let networkService: NetworkRepository
    
    init(networkService: NetworkRepository = NetworkRepositoryImpl(session: SSLSessionFactory.makePinnedSession())) {
        self.networkService = networkService
    }
    
    func detailNews(with id: Int, detailType: DetailType, completion: @escaping DetailItemResult) {
        guard let url = detailType.url(with: id) else { return }
        
        networkService.fetchRequest(url) { networkResult in
            switch networkResult {
            case .success(let response):
                let (urlResponse, data) = response
                guard urlResponse.statusCode.isOk else {
                    completion(.failure(.loading))
                    return
                }
                self.parse(data: data, result: completion)
            case .failure(let error):
                completion(.failure(.loading))
           }
        }
    }
    
    private func parse(data: Any, result: @escaping DetailItemResult) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let decoder = JSONDecoder()
            let blogResponse = try decoder.decode(Blog.self, from: jsonData)
            result(.success(blogResponse))
        } catch {
            result(.failure(.parsing))
        }
    }
}
