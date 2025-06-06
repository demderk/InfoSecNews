//
//  NewsResolver.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 09.03.2025.
//

import Foundation
import Swift

@Observable
final class NewsResolver<T: NewsProvider> {
    var newsCollection: [T.NewsItem] = []
    var webKit: WebKitHead { dataVoyager.webKit }
    var pagesDelay: Duration = .seconds(1)

    private var dataVoyager: WebVoyager = .init()
    private var newsProvider: T

    init(_ newsProvider: T) {
        self.newsProvider = newsProvider
    }

    func fetch() async {
        let remoteResult = await dataVoyager.fetch(url: newsProvider.nextUrlString)
        guard case let .success(remoteHTML) = remoteResult else {
            return
        }

        let parsedResults = newsProvider.parse(input: remoteHTML)
        guard !parsedResults.isEmpty else { return }

        newsProvider.pageNumber += 1
        newsCollection.append(contentsOf: parsedResults)
    }

    func fetch(until: Date) async {
        while true {
            await fetch()
            let lastDate = newsCollection
                .sorted(by: { $0.date > $1.date })
                .last?
                .date

            guard let lastDate = lastDate else { return }

            let components = Calendar.current.dateComponents([.day], from: lastDate, to: until)
            if let days = components.day, days >= 1 {
                break
            }
            try? await Task.sleep(for: pagesDelay)
        }
    }

    func fetch(daysAgo: Int) async {
        let date = Date()
        guard let dateTo = Calendar.current.date(byAdding: .day, value: -daysAgo, to: date) else {
            return
        }
        await fetch(until: dateTo)
    }

    func preloaded() -> Self {
        Task {
            await fetch()
        }
        return self
    }
}
