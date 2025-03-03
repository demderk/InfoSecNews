//
//  NewsItem.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import Foundation

struct NewsItem: Hashable {
    var id = UUID()
    
    var source: String
    var title: String
    var date: Date
    var short: String
    var fullTextLink: URL
    var full: String?
    var fullParserStrategy: ((NewsItem, String) -> [NewsItem])?

    func hash(into hasher: inout Hasher) {
         hasher.combine(source)
         hasher.combine(title)
         hasher.combine(date)
         hasher.combine(short)
         hasher.combine(fullTextLink)
         hasher.combine(full)
     }

     static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
         return lhs.source == rhs.source &&
                lhs.title == rhs.title &&
                lhs.date == rhs.date &&
                lhs.short == rhs.short &&
                lhs.fullTextLink == rhs.fullTextLink &&
                lhs.full == rhs.full
     }
}
