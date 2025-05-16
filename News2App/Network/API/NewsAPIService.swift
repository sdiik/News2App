//
//  NewsAPIService.swift
//  NewsApp
//
//  Created by ahmad shiddiq on 24/04/25.
//

import Foundation

struct NewsAPIService {
    
    func makeArticlesURL(withQuery query: String? = nil) -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.articles)
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        if let query = query {
            components?.queryItems?.append(URLQueryItem(name: "search", value: query))
        }
        return components?.url
    }
    
    func makeBlogsURL(withQuery query: String? = nil) -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.blogs)
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        if let query = query {
            components?.queryItems?.append(URLQueryItem(name: "search", value: query))
        }
        return components?.url
    }
    
    func makeReportsURL(withQuery query: String? = nil) -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.reports)
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        if let query = query {
            components?.queryItems?.append(URLQueryItem(name: "search", value: query))
        }
        return components?.url
    }
    
    func makeInfoURL() -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.info)
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        return components?.url
    }
    
    func makeDetailArticlesURL(with id: Int) -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.articles+"/\(id)")
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        return components?.url
    }
    
    func makeDetailBlogsURL(with id: Int) -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.blogs+"/\(id)")
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        return components?.url
    }
    
    func makeDetailReportsURL(with id: Int) -> URL? {
        var components = URLComponents(string: NetworkConstants.baseURL + NetworkConstants.Endpoints.reports+"/\(id)")
        components?.queryItems = [
            URLQueryItem(name: "format", value: "json")
        ]
        return components?.url
    }
}
