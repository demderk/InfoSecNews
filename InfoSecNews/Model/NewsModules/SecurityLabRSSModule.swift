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
    var news: [SecurityLabNews] = []
    
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
            SecurityLabNews(
                source: moduleName,
                title: title,
                date: date,
                short: short,
                fullTextLink: link))
    }
    
    func remote() {
        
    }
}

@Observable
class SecurityLabRSSModule: RSSNewsModule {
    
    var url: URL = URL(string: "https://www.securitylab.ru/_services/export/rss/")!
    var moduleName: String = "Security Lab"
    var newsCollection: [SecurityLabNews] = []
    
    private var parserDelegate = SecurityLabRSSParserDelegate()
    
    func fetch() async -> [SecurityLabNews] {
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
