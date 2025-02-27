//
//  RSSNewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 27.02.2025.
//
protocol RSSNewsModule: NewsModule {
    func fetch() async -> [NewsItem]
}

extension RSSNewsModule {
    func pull() {
        Task {
            let news = await fetch()
            newsCollection = news
        }
    }
}
