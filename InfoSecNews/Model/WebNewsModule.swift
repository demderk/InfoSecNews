//
//  WEBNewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 27.02.2025.
//

import WebKit

protocol WebNewsModule: AnyObject, NewsModule {
    var webKit: WebKitHead { get set }
    var htmlBody: String? { get set }
    
    func fetch() throws -> [NewsItem]
    func loadFinished(_ html: String?, _ webView: WKWebView)
    func DOMUpdated(_ html: String?, _ webView: WKWebView)
}

extension WebNewsModule {
    func preloaded() -> Self {
        webKit.load(url: url)
        return self
    }
    
    func pull() throws {
        newsCollection = try fetch()
    }
    
    func webKitSetup() {
        webKit.subscribeDOMUpdateAction(action: DOMUpdated)
        webKit.subscribeLoadAction(action: loadFinished)
    }
    
    func loadFinished(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
    
    func DOMUpdated(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
}
