//
//  NewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//

import Foundation

protocol NewsModule: AnyObject {
    associatedtype NewsItem: NewsBehavior

    var id: UUID { get }
    var url: URL { get }
    var moduleName: String { get }
    var newsCollection: [NewsItem] { get set }
}

extension NewsModule {
    var id: UUID { UUID() }
}
