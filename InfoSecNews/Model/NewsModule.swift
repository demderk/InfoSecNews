//
//  NewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//

import Foundation

protocol NewsModule : AnyObject {
    var id: UUID { get }
    var url: URL { get }
    var windowID: String { get }
    var moduleName: String { get }
    var webWindow: WebView { get }
    
    var htmlBody: String? { get }
//    var newsCollection: [NewsItem]? { get }
    
    func parse() throws -> [NewsItem]
}

extension NewsModule {
    var id: UUID { UUID() }
}
