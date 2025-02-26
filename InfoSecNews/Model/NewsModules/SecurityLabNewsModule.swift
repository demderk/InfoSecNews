//
//  SecurityLabNewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 25.02.2025.
//

import Foundation
import SwiftSoup

@Observable
final class SecurityLabNewsModule: NewsModule {
    var url: URL = URL(string: "https://www.securitylab.ru/news/")!
    
    var moduleName: String = "SecurityLab"
    
    var webKit: WebKitHead = WebKitHead()
    
    var htmlBody: String? {
        didSet {
            try! pull()
        }
    }
    
    var newsCollection: [NewsItem] = []
    
    init() {
        webKitSetup()
    }
    
    func fetch() throws -> [NewsItem] {
        guard let htmlBody = htmlBody else {
            return []
        }
        
        let htDoc = try SwiftSoup.parse(htmlBody)
        
        let x = try htDoc.select(".article-card-details")
        
        var news: [NewsItem] = []
        
        for item in x {
            var newsTitle: String?
            var newsDate: Date?
            var newsShort: String?
            
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
            
            if newsTitle?.isEmpty ?? true,
               newsDate == nil,
               newsShort?.isEmpty ?? true
            {
                continue
            }
            
            guard let newsTitle = newsTitle, let newsDate = newsDate, let newsShort = newsShort else {
                continue
            }
            
            news.append(
                NewsItem(
                    source: moduleName,
                    title: newsTitle.trimmingCharacters(in: .whitespaces),
                    date: newsDate,
                    short: newsShort.trimmingCharacters(in: .whitespaces)))
        }
        
        return news
    }
}
