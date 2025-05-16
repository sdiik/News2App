//
//  AppDIContainer.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 22/04/25.
//

import Foundation

enum AppDIContainer {
    static func makeNetworkRepository() -> NetworkRepository {
        let secureSession = SSLSessionFactory.makePinnedSession()
        return NetworkRepositoryImpl(session: secureSession)
    }
}
