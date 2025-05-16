//
//  NetworkRepositoryImpl.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Alamofire

struct NetworkRepositoryImpl: NetworkRepository {
    let session: Session

    init(session: Session = AF) {
        self.session = session
    }

    func fetchRequest(_ url: URL, result: @escaping FetchRequestResult) {
        session.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(data):
                    if let httpResponse = response.response {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            result(.success((httpResponse, json)))
                        } catch {
                            result(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "Error", code: 0, userInfo: nil)
                        result(.failure(error))
                    }
                case let .failure(error):
                    result(.failure(error))
                }
            }
    }
}
