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
    
    var requestQueue: [(newsItem: NewsItem, onComplete: ([NewsItem]) -> Void)] = []
    var bussy: Bool = false
    
    init() {
        webKitSetup()
    }
    
    func fetch(newsItem: NewsItem, onComplete: @escaping ([NewsItem]) -> Void) {
        webKit.singleLoadAction { html, _ in
            guard let html = html else { return }
            if let strategy = newsItem.fullParserStrategy?(newsItem, html) {
                onComplete(strategy)
            }
        }
        webKit.load(url: newsItem.fullTextLink)
    }
    
    func addRequest(newsItem: NewsItem, action: @escaping ([NewsItem]) -> Void) {
        requestQueue.append((newsItem, action))
    }
    
    func processQueue() {
        guard bussy == false else { return }
        if let request = requestQueue.first {
            bussy = true
            fetch(newsItem: request.newsItem) { [self] in
                request.onComplete($0)
                requestQueue.removeFirst()
                bussy = false
                processQueue()
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
