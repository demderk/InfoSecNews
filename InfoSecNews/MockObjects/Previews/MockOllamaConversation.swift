//
//  MockOllamaConversation.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.05.2025.
//

import Foundation

// swiftlint:disable line_length
class MockOllamaConversation: OllamaConversation {
    init() {
        let mockNewsItem = SecurityLabNews(
            source: "debug.fm",
            title: "Белый дом запретит судам принимать иски против Белого дома",
            date: .now,
            short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
            full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
        super.init(ollamaRemote: OllamaRemote(url: URL(string: "example.com")!), model: .gemma31b, chatData: ChatData(news: mockNewsItem, messageHistory: []))
        pull(role: .assistant,
             message: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
        pull(role: .assistant, message: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
        pull(role: .user, message: "Почему белый дом, белый?")
        pull(role: .assistant, message: "хз...")
    }
}
// swiftlint:enable line_length


class MockChatData: ChatData {
    init() {
        let mockNewsItem = MockNewsItem()
        super.init(news: mockNewsItem, messageHistory: [])
        pull(role: .assistant,
             message: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
        pull(role: .assistant, message: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
        pull(role: .user, message: "Почему белый дом, белый?")
        pull(role: .assistant, message: "хз...")
    }
}
