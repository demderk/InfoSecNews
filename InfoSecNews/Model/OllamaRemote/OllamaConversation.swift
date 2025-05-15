//
//  OllamaConversation.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 02.05.2025.
//

import Foundation
import os

@Observable
class ChatMessage: Identifiable {
    var id = UUID()
    
    var role: MLRole
    var content: String
    
    init(_ base: MLMessage) {
        role = base.role
        content = base.content
    }
    
    init(role: MLRole, content: String) {
        self.role = role
        self.content = content
    }
    
    func asMLMessage() -> MLMessage {
        MLMessage(role: role, content: content)
    }
}

enum MLConversationError: Error {
    case emptyNewsBody
}

@Observable
class OllamaConversation: Identifiable {
    let id = UUID()
    
    let remote: OllamaRemote
    let newsItem: any NewsBehavior
    
    private(set) var storage: [ChatMessage] = []
    
    // MARK: UI Properties
    
    private var selectedResponse: ChatMessage?
    
    var selectedContent: String {
        if let content = selectedResponse {
            return content.content
        }
        if let content = storage.first(where: { $0.role == .assistant })?.content {
            return content
        } else {
            return "This news is still pending delivery to the target"
        }
    }
    
    var newsContent: String {
        guard let content = newsItem.full else {
            // swiftlint:disable:next line_length
            Logger.UILogger.warning("[OllamaConversation] NewsItem with nil \"full\" was found. Using default \"short\".")
            return newsItem.short
        }
        return content
    }
    
    // END
    
    init(ollamaRemote: OllamaRemote, newsItem: any NewsBehavior) {
        self.remote = ollamaRemote
        self.newsItem = newsItem
    }
    
    @discardableResult
    func sendMessage(prompt: String, makeSelected: Bool = false) async throws -> ChatMessage {
        let userMessage = ChatMessage(MLMessage(role: .user, content: prompt))
        
        let chatRequest = MLChatRequest(
            model: remote.selectedModel.name,
            messages: storage.map({ $0.asMLMessage() }) + [userMessage.asMLMessage()])
        
        let stream = try await remote.chatStream(chatRequest: chatRequest)
        let assistantMessage = ChatMessage(MLMessage(role: .assistant, content: ""))
        
        storage.append(userMessage)
        storage.append(assistantMessage)
        
        if makeSelected {
            selectedResponse = assistantMessage
        }
        
        for try await item in stream {
            assistantMessage.content += item.message.content
            print(assistantMessage.content)
        }
        
        return assistantMessage
    }
    
    func pull(role: MLRole, message: String) {
        let message = ChatMessage(role: role, content: message)
        storage.append(message)
    }
    
    func sumarize() async throws {
        guard let full = newsItem.full else {
            throw MLConversationError.emptyNewsBody
        }
        
        // TODO: Import system message for summarization
        let instructions = ChatMessage(
            role: .user,
            content: "Сумаризируй сообщение ниже. Нужно в 2-3 предложения."
        )
        storage.append(instructions)
        
        try await sendMessage(prompt: full, makeSelected: true)
    }
}
