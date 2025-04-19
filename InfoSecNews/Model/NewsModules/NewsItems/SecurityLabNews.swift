//
//  SecurityLabNews.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.03.2025.
//

import Foundation
import SwiftSoup

final class SecurityLabNews: NewsBehavior {    
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
    
    convenience init(source: String,
                     title: String,
                     date: Date,
                     short: String,
                     fullTextLink: URL,
                     full: String
    ) {
        self.init(source: source, title: title, date: date, short: short, fullTextLink: fullTextLink)
        self.full = full
    }
    
    func loadRemoteData(voyager: WebVoyager) async throws {
        let input = await voyager.fetch(url: fullTextLink)
        
        if case .success(let html) = input {
            parseFullArticle(html: html)
        } else {
            switch input {
            case .success(let html):
                parseFullArticle(html: html)
            case .failure(let failure):
                throw failure
            }
        }
    }
    
    private func parseFullArticle(html: String) {
        
        let htDoc = try! SwiftSoup.parse(html)
        let htmlNews = try! htDoc.select(".cpb")
                
        for item in htmlNews {
            var newsFull: String?
            if let full = try? item.select("[itemprop=description]").first() {
                var innerText = ""
                let allTextNodes = full.getChildNodes()
                    .flatMap({ $0.getChildNodes().count > 0 ? $0.getChildNodes() : [$0] })
                    .compactMap({ $0 as? TextNode })
                for item in allTextNodes {
                    if let text = try? item.outerHtml(), !text.isEmpty {
                        if text == " " {
                            innerText += "\n\n"
                        } else {
                            innerText += text.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    } else { continue }
                }
                newsFull = innerText.trimmingCharacters(in: ["\n"])
            }
            full = newsFull
            return
        }
    }
}
