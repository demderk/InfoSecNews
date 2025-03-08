//
//  SecurityMediaNewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//
import Foundation
import SwiftSoup
import WebKit
import Combine

@Observable
final class SecurityMediaModule2 {
    var baseUrl: URL = URL(string: "https://securitymedia.org/news/")!
    var moduleName: String = "SecurityMedia"
    
    var newsCollection: [SecurityMediaNews] = []
    var webKit: WebKitHead { dataVoyager.webKit }
    
    private var dataVoyager: WebVoyager = WebVoyager()
    
    private var pageNumber: Int = 0
    private var currentUrlString: URL { URL(string: "https://securitymedia.org/news/?PAGEN_3=\(pageNumber)")! }
    private var nextUrlString: URL { URL(string: "https://securitymedia.org/news/?PAGEN_3=\(pageNumber + 1)")! }
    
    func parse(html: String) -> [SecurityMediaNews] {
        guard let htDoc = try? SwiftSoup.parse(html),
              let htmlNews = try? htDoc.select("div.col-md-8")
        else {
            return []
        }
        
        var news: [SecurityMediaNews] = []
        
        for item in htmlNews {
            var newsTitle: String?
            var newsDate: Date?
            var newsShort: String?
            var newsFullLink: URL?
            
            if let title = try? item.select(".h4").text() {
                newsTitle = title
            }
            
            if let date = try? item.select(".date_time").text() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                newsDate = dateFormatter.date(from: date)
            }
            
            if let short = try? item.select("a").first() {
                newsShort = short.textNodes().last?.text()
                if let textLink = try? ("https://securitymedia.org\(short.attr("href"))") {
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
                SecurityMediaNews(
                    source: moduleName,
                    title: newsTitle.trimmingCharacters(in: .whitespaces),
                    date: newsDate,
                    short: newsShort.trimmingCharacters(in: .whitespaces),
                    fullTextLink: newsFullLink))
        }
        
        return news
    }
    
    func fetch() async {
        let remoteResult = await dataVoyager.fetch(url: nextUrlString)
        guard case .success(let remoteHTML) = remoteResult else {
            return
        }
        
        let parsedResults = parse(html: remoteHTML)
        guard !parsedResults.isEmpty else { return }
        
        pageNumber += 1
        newsCollection.append(contentsOf: parsedResults)
    }
    
    func fetch(pageCount: Int) async {
        for _ in 1...pageCount {
            await fetch()
            try? await Task.sleep(for: .seconds(1))
        }
    }
    
    func preloaded() -> Self {
        Task {
            await fetch()
        }
        return self
    }
}

//@Observable
//final class SecurityMediaNewsModule: WebNewsModule {
//    var webKit: WebKitHead = WebKitHead()
//    
//    var newsCollection: [SecurityMediaNews] = []
//    
//    var url: URL = URL(string: "https://securitymedia.org/news/")!
//    var moduleName: String = "SecurityMedia"
//    var htmlBody: String? {
//        didSet {
//            try! pull()
//        }
//    }
//        
//    init() {
//        webKitSetup()
//    }
//        
//    func fetch() throws -> [SecurityMediaNews] {
//        guard let htmlBody = htmlBody else {
//            return []
//        }
//        
//        return parse(html: htmlBody)
//    }
//        
//    func parse(html: String) -> [SecurityMediaNews] {
//        guard let htDoc = try? SwiftSoup.parse(html),
//              let htmlNews = try? htDoc.select("div.col-md-8")
//        else {
//            return []
//        }
//        
//        var news: [NewsItem] = []
//        
//        for item in htmlNews {
//            var newsTitle: String?
//            var newsDate: Date?
//            var newsShort: String?
//            var newsFullLink: URL?
//            
//            if let title = try? item.select(".h4").text() {
//                newsTitle = title
//            }
//            
//            if let date = try? item.select(".date_time").text() {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "dd.MM.yyyy"
//                newsDate = dateFormatter.date(from: date)
//            }
//            
//            if let short = try? item.select("a").first() {
//                newsShort = short.textNodes().last?.text()
//                if let textLink = try? ("https://securitymedia.org\(short.attr("href"))") {
//                    newsFullLink = URL(string: textLink)
//                }
//            }
//            
//            if newsTitle?.isEmpty ?? true,
//               newsDate == nil,
//               newsShort?.isEmpty ?? true
//            {
//                continue
//            }
//            
//            guard let newsTitle = newsTitle,
//                  let newsDate = newsDate,
//                  let newsShort = newsShort,
//                  let newsFullLink = newsFullLink
//            else {
//                continue
//            }
//            
//            news.append(
//                NewsItem(
//                    source: moduleName,
//                    title: newsTitle.trimmingCharacters(in: .whitespaces),
//                    date: newsDate,
//                    short: newsShort.trimmingCharacters(in: .whitespaces),
//                    fullTextLink: newsFullLink))
//        }
//        
//        return news
//    }
//    
//    func next() {
//        
//    }
//}
