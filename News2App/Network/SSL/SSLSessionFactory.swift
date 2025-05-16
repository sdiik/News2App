//
//  SSLSessionFactory.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Alamofire

enum SSLSessionFactory {
    static func makePinnedSession() -> Session {
        let evaluators: [String: ServerTrustEvaluating] = [
            API_HOST : PinnedCertificatesTrustEvaluator(
                certificates: Bundle.main.af.certificates,
                acceptSelfSignedCertificates: false,
                performDefaultValidation: true,
                validateHost: true
            )
        ]

        let trustManager = ServerTrustManager(evaluators: evaluators)
        let configuration = URLSessionConfiguration.af.default

        return Session(configuration: configuration, serverTrustManager: trustManager)
    }
}
