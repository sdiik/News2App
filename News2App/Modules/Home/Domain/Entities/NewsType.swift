//
//  NewsType.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 23/04/25.
//

import Foundation

enum NewsType: Int, CaseIterable {
    case article = 0
    case blog = 1
    case report = 2

    var url: URL? {
        switch self {
        case .article:
            return NewsAPIService().makeArticlesURL()
        case .blog:
            return NewsAPIService().makeBlogsURL()
        case .report:
            return NewsAPIService().makeReportsURL()
        }
    }

    func url(with query: String) -> URL? {
        switch self {
        case .article:
            return NewsAPIService().makeArticlesURL(withQuery: query)
        case .blog:
            return NewsAPIService().makeBlogsURL(withQuery: query)
        case .report:
            return NewsAPIService().makeReportsURL(withQuery: query)
        }
    }

    var title: String {
        switch self {
        case .article:
            return "Articles"
        case .blog:
            return "Blogs"
        case .report:
            return "Reports"
        }
    }
}
