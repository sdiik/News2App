//
//  DetailType.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

import Foundation

enum DetailType: Int, CaseIterable {
    case articles = 0
    case blogs = 1
    case reports = 2

    func url(with id: Int) -> URL? {
        switch self {
        case .articles:
            return NewsAPIService().makeDetailArticlesURL(with: id)
        case .blogs:
            return NewsAPIService().makeDetailBlogsURL(with: id)
        case .reports:
            return NewsAPIService().makeDetailReportsURL(with: id)
        }
    }
}
