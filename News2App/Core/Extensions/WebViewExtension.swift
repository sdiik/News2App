//
//  WebViewExtension.swift
//  News2App
//
//  Created by ahmad shiddiq on 02/05/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context _: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    typealias UIViewType = WKWebView
}
