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
    var news: any NewsBehavior
    var messageHistory: [ChatMessage]
    var selectedMessage: ChatMessage?
    
    init(news: any NewsBehavior, messageHistory: [ChatMessage]) {
        self.news = news
        self.messageHistory = messageHistory
    }
    
    // MARK: UI Properties
    
    var selectedContent: String {
        if let content = selectedMessage {
            return content.content
        }
        if let content = messageHistory.first(where: { $0.role == .assistant })?.content {
            return content
        } else {
            return "This news is still pending delivery to the target"
        }
    }
    
    var newsContent: String {
        guard let content = news.full else {
            // swiftlint:disable:next line_length
            Logger.UILogger.warning("[OllamaDialog] NewsItem with nil \"full\" was found. Using default \"short\".")
            return news.short
        }
        return content
    }
    
    // END
    
    func pull(role: MLRole, message: String) {
        let message = ChatMessage(role: role, content: message)
        messageHistory.append(message)
    }
    
    func clearHistory() {
        selectedMessage = nil
        messageHistory.removeAll()
    }
}
