//
//  NewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//

import Foundation
import WebKit

protocol NewsModule : AnyObject, ObservableObject {    
    var id: UUID { get }
    var url: URL { get }
    var moduleName: String { get }
    var webKit: WebKitHead { get set }

    var htmlBody: String? { get set }
    var newsCollection: [NewsItem] { get set }
    
    func fetch() throws -> [NewsItem]
    func loadFinished(_ html: String?, _ webView: WKWebView)
    func DOMUpdated(_ html: String?, _ webView: WKWebView)
}

extension NewsModule {
    var id: UUID { UUID() }
        
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
