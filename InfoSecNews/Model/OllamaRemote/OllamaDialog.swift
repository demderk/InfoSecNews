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

    var storage: [ChatMessage] { chatData.messageHistory }

    @discardableResult
    func sendMessage(prompt: String, makeSelected: Bool = false) async throws -> ChatMessage {
        let userMessage = ChatMessage(MLMessage(role: .user, content: prompt))

        let chatRequest = MLChatRequest(
            model: model.name,
            messages: chatData.messageHistory.map { $0.asMLMessage() } + [userMessage.asMLMessage()]
        )

        let stream = try await remote.chatStream(chatRequest: chatRequest)
        let assistantMessage = ChatMessage(MLMessage(role: .assistant, content: ""))

        chatData.messageHistory.append(userMessage)
        chatData.messageHistory.append(assistantMessage)

        if makeSelected {
            chatData.selectedMessage = assistantMessage
        }

        for try await item in stream {
            assistantMessage.content += item.message.content
            print(assistantMessage.content)
        }

        return assistantMessage
    }

    func pull(role: MLRole, message: String) {
        chatData.pull(role: role, message: message)
    }

    func sumarize() async throws {
        guard let full = chatData.news.full else {
            throw MLConversationError.emptyNewsBody
        }

        // TODO: Import system message for summarization
        let instructions = ChatMessage(
            role: .user,
            content: "Сумаризируй сообщение ниже. Нужно в 2-3 предложения."
        )
        chatData.messageHistory.append(instructions)

        try await sendMessage(prompt: full, makeSelected: true)
    }

    func setSelectedMessage(_ message: ChatMessage) {
        chatData.selectedMessage = message
    }
}
