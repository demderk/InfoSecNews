//
//  WebVoyager.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 28.02.2025.
//

import Foundation
import WebKit

typealias ParseStrategy = (String) -> [NewsItem]

class WebVoyager {
    
    var url: URL = URL(string: "https://en.wikipedia.org/wiki/Duck")!
    var moduleName: String = "WebVoyager"
    var webKit: WebKitHead = WebKitHead()
    var htmlBody: String?
    var newsCollection: [NewsItem] = []
        
    init() {
        webKitSetup()
    }
    
    func fetch(newsItem: NewsItem, onComplete: @escaping ([NewsItem]) -> Void) {
        webKit.load(url: newsItem.fullTextLink)
        webKit.singleLoadAction { html, _ in
            guard let html = html else { return }
            if let strategy = newsItem.fullParserStrategy?(newsItem, html) {
                onComplete(strategy)
            }
        }
    }
    
    func webKitSetup() {
        webKit.subscribeDOMUpdateAction(action: DOMUpdated)
        webKit.subscribeLoadFinished(action: loadFinished)
    }
    
    func loadFinished(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
    
    func DOMUpdated(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
}
