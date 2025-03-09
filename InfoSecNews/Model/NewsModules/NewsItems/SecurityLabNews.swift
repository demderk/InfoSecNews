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
    
    func loadRemoteData(voyager: WebVoyager) async {
        let input = await voyager.fetch(url: fullTextLink)
        
        if case .success(let html) = input {
            parseFullArticle(html: html)
        } else {
            fatalError("Error")
        }
    }
    
    private func parseFullArticle(html: String) {
        
        let htDoc = try! SwiftSoup.parse(html)
        let htmlNews = try! htDoc.select(".cpb")
                
        for item in htmlNews {
            var newsFull: String?
            if let full = try? item.select("[itemprop=description]").first() {
                var innerText = ""
                for item in full.children() {
                    innerText += try! item.text()
                    innerText += "\n\n"
                }
                newsFull = innerText.trimmingCharacters(in: ["\n"])
            }
            full = newsFull
            return
        }
    }
}
