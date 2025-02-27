//
//  NewsItem.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import Foundation

struct NewsItem: Hashable {
    var source: String
    var title: String
    var date: Date
    var short: String
    var fullTextLink: URL
    var full: String?
}
