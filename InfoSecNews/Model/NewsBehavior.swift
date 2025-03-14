//
//  NewsItem.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import Foundation

protocol NewsBehavior: Hashable, Identifiable, AnyObject {    
    var source: String { get }
    var title: String { get }
    var date: Date { get }
    var short: String { get }
    var fullTextLink: URL { get }
    var full: String? { get }

    func loadRemoteData(voyager: WebVoyager) async throws
}

extension NewsBehavior {
    func hash(into hasher: inout Hasher) {
         hasher.combine(source)
         hasher.combine(title)
         hasher.combine(date)
         hasher.combine(short)
         hasher.combine(fullTextLink)
         hasher.combine(full)
     }

    static func == (lhs: Self, rhs: Self) -> Bool {
         return lhs.source == rhs.source &&
                lhs.title == rhs.title &&
                lhs.date == rhs.date &&
                lhs.short == rhs.short &&
                lhs.fullTextLink == rhs.fullTextLink &&
                lhs.full == rhs.full
     }
}
