//
//  OllamaDialog.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 02.05.2025.
//

import Foundation
import os

@Observable
class OllamaDialog: Identifiable {
    var id: ObjectIdentifier { chatData.id }

    let remote: OllamaRemote
    let model: MLModel
    let chatData: ChatData

    init(ollamaRemote: OllamaRemote, model: MLModel, chatData: ChatData) {
        remote = ollamaRemote
        self.model = model
        self.chatData = chatData
    }

    var storage: [ChatMessage] { chatData.history() }

    @discardableResult
    func sendMessage(prompt: String, makeSelected: Bool = false) async throws -> ChatMessage {
        let userMessage = ChatMessage(MLMessage(role: .user, content: prompt))

        let chatRequest = MLChatRequest(
            model: model.name,
            messages: chatData.mlHistory(appending: userMessage)
        )

        let stream = try await remote.chatStream(chatRequest: chatRequest)
        let assistantMessage = ChatMessage(MLMessage(role: .assistant, content: ""))

        chatData.push(message: userMessage)
        chatData.push(message: assistantMessage)

        if makeSelected {
            chatData.selectMessage(assistantMessage)
        }

        for try await item in stream {
            assistantMessage.content += item.message.content
        }

        return assistantMessage
    }

    func pull(role: MLRole, message: String) {
        chatData.push(role: role, message: message)
    }

    func sumarize(systemMessage: String) async throws {
        guard let full = chatData.news.full else {
            throw MLConversationError.emptyNewsBody
        }

        if !systemMessage.isEmpty {
            chatData.setSystemMessage(systemMessage)
        }

        try await sendMessage(prompt: full, makeSelected: true)
    }

    func setSelectedMessage(_ message: ChatMessage) {
        chatData.selectMessage(message)
    }
}
