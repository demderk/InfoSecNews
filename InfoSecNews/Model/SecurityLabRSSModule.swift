//
//  SecurityLabRSSModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 27.02.2025.
//

import Foundation
import SwiftSoup

private class SecurityLabRSSParserDelegate: NSObject, XMLParserDelegate {
    
    var lastTitle = ""
    var lastDesc = ""
    var lastLink = ""
    var lastCat = ""
    var lastDate = ""
    
    var moduleName: String = "Security Lab"
    var currentElement: String?
    var news: [NewsItem] = []
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        
        if elementName == "item" {
            lastTitle = ""
            lastDesc = ""
            lastLink = ""
            lastCat = ""
            lastDate = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            lastTitle += string
        case "description":
            lastDesc += string
        case "link":
            lastLink += string
        case "category":
            lastCat += string
        case "pubDate":
            lastDate += string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?
    ) {
        guard elementName == "item" else {
            return
        }
        
        let title = lastTitle.trimmingCharacters(in: ["\n", "\t", " "])
        let short = String(lastDesc
            .trimmingCharacters(in: ["\n", "\t", " "])
            .replacingOccurrences(of: "<br />", with: "")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#37;", with: "%"))
        let link = URL(string: lastLink.trimmingCharacters(in: ["\n", "\t", " "]))
        let cat = lastCat.trimmingCharacters(in: ["\n", "\t", " "])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: lastDate.trimmingCharacters(in: ["\n", "\t", " "]))
        
        guard cat != "Блоги" else {
            return
        }
        
        guard !title.isEmpty,
              !short.isEmpty,
              let link = link,
              let date = date
        else {
            return
        }
        
        news.append(
            NewsItem(
                source: moduleName,
                title: title,
                date: date,
                short: short,
                fullTextLink: link,
                fullParserStrategy: parseFull))
    }
    
    func parseFull(parent: NewsItem, html: String) -> [NewsItem] {
        
        let htDoc = try! SwiftSoup.parse(html)
        
        let x = try! htDoc.select(".cpb")
        
        var news: [NewsItem] = []
        
        for item in x {
            var newsTitle: String?
            var newsDate: Date?
            var newsFull: String?
            
            if let title = try? item.select(".page-title").text() {
                newsTitle = title
            }
            
            if let date = try? item.select("time").attr("datetime") {
                let dateFormatter = ISO8601DateFormatter()
                newsDate = dateFormatter.date(from: date)
            }
            
            if let full = try? item.select("[itemprop=description]").first() {
                newsFull = try? full.text()
            }
            
            guard newsTitle == parent.title, newsDate == parent.date else {
                print("Can't connect full news with short news")
                continue
            }
            
            guard !(newsTitle?.isEmpty ?? true), newsDate != nil else {
                continue
            }
            
            var newItem = parent
            newItem.full = newsFull
            
            news.append(newItem)
        }
        
        return news
    }

}

@Observable
class SecurityLabRSSModule: RSSNewsModule {
    
    var url: URL = URL(string: "https://www.securitylab.ru/_services/export/rss/")!
    var moduleName: String = "Security Lab"
    var newsCollection: [NewsItem] = []
    
    private var parserDelegate = SecurityLabRSSParserDelegate()
    
    func fetch() async -> [NewsItem] {
        let rssLink = URL(string: "https://www.securitylab.ru/_services/export/rss")!
        var rssRequest = URLRequest(url: rssLink)
        rssRequest.httpMethod = "GET"
        
        let (data, _) = try! await URLSession.shared.data(for: rssRequest)
        
        let parser = XMLParser(data: data)
        parser.delegate = parserDelegate
        parser.parse()
        
        return parserDelegate.news
    }
    
    func preloaded() -> Self {
        pull()
        return self
    }
}
