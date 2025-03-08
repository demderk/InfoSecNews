//
//  SecurityLabModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 09.03.2025.
//

import Foundation
import SwiftSoup

final class SecurityLabModule: NewsProvider {
    var baseUrl: URL = URL(string: "https://www.securitylab.ru/news/")!
    var moduleName: String = "Security Lab"
    
    var pageNumber: Int = 0
    var currentUrlString: URL { URL(string: "https://www.securitylab.ru/news/page1_\(pageNumber).php")! }
    var nextUrlString: URL { URL(string: "https://www.securitylab.ru/news/page1_\(pageNumber+1).php")! }
    
    func parse(input html: String) -> [SecurityLabNews] {
        guard let htDoc = try? SwiftSoup.parse(html),
              let htmlNews = try? htDoc.select(".article-card")
        else {
            return []
        }
        
        var news: [SecurityLabNews] = []
        
        for item in htmlNews {
            var newsTitle: String?
            var newsDate: Date?
            var newsShort: String?
            var newsFullLink: URL?
            
            if let title = try? item.select(".article-card-title").text() {
                newsTitle = title
            }
            
            if let date = try? item.select("time").attr("datetime") {
                let dateFormatter = ISO8601DateFormatter()
                newsDate = dateFormatter.date(from: date)
            }
            
            if let short = try? item.select("p").first() {
                newsShort = short.textNodes().last?.text()
            }
            
            if let short = try? item.select("a").first() {
                if let textLink = try? ("https://securitylab.ru\(short.attr("href"))") {
                    newsFullLink = URL(string: textLink)
                }
            }
            
            if newsTitle?.isEmpty ?? true,
               newsDate == nil,
               newsShort?.isEmpty ?? true
            {
                continue
            }
            
            guard let newsTitle = newsTitle,
                  let newsDate = newsDate,
                  let newsShort = newsShort,
                  let newsFullLink = newsFullLink
            else {
                continue
            }
            
            news.append(
                SecurityLabNews(
                    source: moduleName,
                    title: newsTitle.trimmingCharacters(in: .whitespaces),
                    date: newsDate,
                    short: newsShort.trimmingCharacters(in: .whitespaces),
                    fullTextLink: newsFullLink))
        }
        
        return news
    }
}
