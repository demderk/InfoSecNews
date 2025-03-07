//
//  SecurityMediaNews.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 08.03.2025.
//

import Foundation

class SecurityMediaNews: NewsBehavior {
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
        
    }
}
