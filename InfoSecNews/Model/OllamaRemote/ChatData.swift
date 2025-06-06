//
//  ChatData.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 20.05.2025.
//

import Foundation
import os

@Observable
class ChatData: Identifiable {
    let news: any NewsBehavior
    private var messageHistory: [ChatMessage]
    private(set) var selectedMessage: ChatMessage?

    private var internalSystemMessage: ChatMessage?

    var systemMessage: ChatMessage? {
        internalSystemMessage
    }

    init(news: any NewsBehavior, messageHistory: [ChatMessage]) {
        self.news = news
        self.messageHistory = messageHistory
    }

    // MARK: UI Properties

    var UISelectedContent: String {
        if let content = selectedMessage {
            return content.content
        }
        if let content = messageHistory.first(where: { $0.role == .assistant })?.content {
            return content
        } else {
            return "This news is still pending delivery to the target"
        }
    }

    var UINewsContent: String {
        guard let content = news.full else {
            // swiftlint:disable:next line_length
            Logger.UILogger.warning("[OllamaDialog] NewsItem with nil \"full\" was found. Using default \"short\".")
            return news.short
        }
        return content
    }

    // END

    func push(role: MLRole, message: String) {
        let message = ChatMessage(role: role, content: message)
        messageHistory.append(message)
    }

    func push(message: ChatMessage) {
        messageHistory.append(message)
    }

    func clearHistory() {
        selectedMessage = nil
        messageHistory.removeAll()
    }

    func setSystemMessage(_ message: String) {
        internalSystemMessage = ChatMessage(
            role: .system,
            content: message
        )
    }

    func selectMessage(_ message: ChatMessage) {
        selectedMessage = message
    }

    func history() -> [ChatMessage] {
        if let system = internalSystemMessage {
            return [system] + messageHistory
        } else {
            return messageHistory
        }
    }

    func history(appending: ChatMessage) -> [ChatMessage] {
        history() + [appending]
    }

    func mlHistory(appending: ChatMessage) -> [MLMessage] {
        history(appending: appending)
            .map { $0.asMLMessage() }
    }
}
