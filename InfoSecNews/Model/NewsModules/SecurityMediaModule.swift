//
//  SecurityMediaModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//
import Foundation
import SwiftSoup

final class SecurityMediaModule: NewsProvider {
    var baseUrl: URL = .init(string: "https://securitymedia.org/news/")!
    var moduleName: String = "SecurityMedia"

    var pageNumber: Int = 0
    var currentUrlString: URL { URL(string: "https://securitymedia.org/news/?PAGEN_3=\(pageNumber)")! }
    var nextUrlString: URL { URL(string: "https://securitymedia.org/news/?PAGEN_3=\(pageNumber + 1)")! }

    func parse(input html: String) -> [SecurityMediaNews] {
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
                    fullTextLink: newsFullLink
                ))
        }

        return news
    }
}
