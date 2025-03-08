//
//  NewsResolver.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 09.03.2025.
//

import Swift
import Foundation

@Observable
final class NewsResolver<T: NewsProvider> {
    var newsCollection: [T.NewsItem] = []
    var webKit: WebKitHead { dataVoyager.webKit }
    
    private var dataVoyager: WebVoyager = WebVoyager()
    private var newsProvider: T
    
    init(_ newsProvider: T) {
        self.newsProvider = newsProvider
    }
    
    func fetch() async {
        let remoteResult = await dataVoyager.fetch(url: newsProvider.nextUrlString)
        guard case .success(let remoteHTML) = remoteResult else {
            return
        }
        
        let parsedResults = newsProvider.parse(input: remoteHTML)
        guard !parsedResults.isEmpty else { return }
        
        newsProvider.pageNumber += 1
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
