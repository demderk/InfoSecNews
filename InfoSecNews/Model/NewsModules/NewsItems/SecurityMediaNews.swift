//
//  SecurityMediaNews.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 08.03.2025.
//

import Foundation
import SwiftSoup

final class SecurityMediaNews: NewsBehavior {
    var source: String
    var title: String
    var date: Date
    var short: String
    var fullTextLink: URL
    var full: String?

    init(source: String, title: String, date: Date, short: String, fullTextLink: URL) {
        self.source = source
        self.title = title
        self.date = date
        self.short = short
        self.fullTextLink = fullTextLink
    }

    func loadRemoteData(voyager: WebVoyager) async throws {
        let input = await voyager.fetch(url: fullTextLink)

        switch input {
        case let .success(html):
            parseFullArticle(html: html)
        case let .failure(failure):
            throw failure
        }
    }

    private func parseFullArticle(html: String) {
        let htDoc = try! SwiftSoup.parse(html)
        let htmlNews = try! htDoc.select(".detail_item")

        for item in htmlNews {
            var newsFull: String?
            if let full = try? item.select(".article-detail").first() {
                var innerText = ""
                for item in full.children() {
                    innerText += try! item.text()
                    innerText += "\n"
                }
                newsFull = innerText.trimmingCharacters(in: ["\n"])
            }
            full = newsFull
            return
        }
    }
}
