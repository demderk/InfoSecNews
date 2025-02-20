//
//  NewsParser.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import Foundation

// securitymedia.org
// securitylab
// antimalware
// cisoclub

class NewsParser {
    func getNews() async {
        var request = URLRequest(url: URL(string: "https://securitylab.ru/news/")!)
        request.httpMethod = "GET"
        request.httpMethod = "GET"
        
        let (d, r) = try! await URLSession.shared.data(for: request)
        
        
        
        print(r)
    }
}
