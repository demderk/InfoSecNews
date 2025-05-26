//
//  NewsItem.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import Foundation

protocol NewsBehavior: Identifiable, AnyObject {
    var source: String { get }
    var title: String { get }
    var date: Date { get }
    var short: String { get }
    var fullTextLink: URL { get }
    var full: String? { get }

    func loadRemoteData(voyager: WebVoyager) async throws
}

extension NewsBehavior {
    func equals(news: any NewsBehavior) -> Bool {
        self.fullTextLink == news.fullTextLink
    }
}
