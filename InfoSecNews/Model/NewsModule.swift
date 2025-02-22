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

    var htmlBody: String? { get set }
    var newsCollection: [NewsItem] { get set }
    
    func fetch() throws -> [NewsItem]
    func loadFinished(_ webView: WKWebView)
    func DOMUpdated()
}

extension NewsModule {
    var id: UUID { UUID() }
    
    func loadFinished(_ webView: WKWebView) {}
    func DOMUpdated() {}
    
    func pull() throws {
        newsCollection = try fetch()
    }
}
