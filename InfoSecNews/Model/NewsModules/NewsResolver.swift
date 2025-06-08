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

    func fetch() async throws {
        let remoteResult = await dataVoyager.fetch(url: newsProvider.nextUrlString)

        let remoteHTML = try remoteResult.get()

        let parsedResults = newsProvider.parse(input: remoteHTML)
        guard !parsedResults.isEmpty else {
            throw RemoteError.emptyParsedData
        }

        newsProvider.pageNumber += 1
        newsCollection.append(contentsOf: parsedResults)
    }

    func fetch(until: Date, maxAttempts: Int = 3) async throws {
        var attempts = 0

        while attempts < maxAttempts {
            try await fetch()
            attempts += 1
            let lastDate = newsCollection
                .sorted(by: { $0.date > $1.date })
                .last?
                .date

            guard let lastDate = lastDate else {
                AppLog.error("Last date is nil")
                throw RemoteError.lastDateIsNil
            }

            let components = Calendar.current.dateComponents([.day], from: lastDate, to: until)
            if let days = components.day, days >= 1 {
                return
            }
            try? await Task.sleep(for: pagesDelay)
        }
        AppLog.error("Max attempts reached")
        throw RemoteError.maxAttemptsReached
    }

    func fetch(daysAgo: Int, maxAttempts: Int = 3) async throws {
        let date = Date()
        guard let dateTo = Calendar.current.date(byAdding: .day, value: -daysAgo, to: date) else {
            return
        }
        try await fetch(until: dateTo, maxAttempts: maxAttempts)
    }
}
