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
class OllamaConversation: Identifiable {
    let id = UUID()
    
    let remote: OllamaRemote
    let newsItem: (any NewsBehavior)?
    //FIXME: PUBLIC SET ONLY FOR DEBUG
    
    var storage: [ChatMessage] = []
    
    var firstResponse: String {
        get {
            storage.first(where: { $0.role == .assistant })?.content ?? ""
        }
        set {
            
        }
    }
    
//    var firstResponseNN: String = storage.first(where: { $0.role == .assistant })?.content ?? ""
    
    init(ollamaRemote: OllamaRemote) {
        self.remote = ollamaRemote
        newsItem = nil
    }
    
    init(ollamaRemote: OllamaRemote, newsItem: any NewsBehavior) {
        self.remote = ollamaRemote
        self.newsItem = newsItem
    }
    
    func sendMessage(prompt: String) async throws {
        let userMessage = ChatMessage(MLMessage(role: .user, content: prompt))
        
        let chatRequest = MLChatRequest(
            model: remote.selectedModel.name,
            messages: storage.map({ $0.asMLMessage() }) + [userMessage.asMLMessage()])
        
        let stream = try await remote.chatStream(chatRequest: chatRequest)
        let assistantMessage = ChatMessage(MLMessage(role: .assistant, content: ""))
        
        storage.append(userMessage)
        storage.append(assistantMessage)
        
        for try await item in stream {
            assistantMessage.content += item.message.content
            print(assistantMessage.content)
        }
    }
}
