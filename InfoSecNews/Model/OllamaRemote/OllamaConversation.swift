//
//  OllamaConversation.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 02.05.2025.
//

import Foundation

@Observable
class ChatMessage: Identifiable {
    var id = UUID()
    
    var role: MLRole
    var content: String
    
    init(_ base: MLMessage) {
        role = base.role
        content = base.content
    }
    
    func asMLMessage() -> MLMessage {
        MLMessage(role: role, content: content)
    }
}

@Observable
class OllamaConversation {
    let remote: OllamaRemote
    private(set) var storage: [ChatMessage] = []
    
    init(ollamaRemote: OllamaRemote) {
        remote = ollamaRemote
    }
    
    func sendMessage(prompt: String) async throws {
        let userMessage = ChatMessage(MLMessage(role: .user, content: prompt))
        
        let chatRequest = MLChatRequest(
            model: remote.selectedModel.name,
            messages: storage.map({ $0.asMLMessage() }) + [userMessage])
        
        let stream = try await remote.chatStream(chatRequest: chatRequest)
        let assistantMessage = ChatMessage(MLMessage(role: .assistant, content: ""))
        
        storage.append(ChatMessage(userMessage))
        storage.append(assistantMessage)
        
        for try await item in stream {
            assistantMessage.content += item.message.content
            print(assistantMessage.content)
        }
    }
}
