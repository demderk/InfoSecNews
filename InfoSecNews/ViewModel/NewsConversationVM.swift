//
//  NewsConversationVM.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation
import os

@Observable
class NewsConversationVM {
    // TODO: Hardcoded creds still here!
    
    let remote = OllamaRemote(url: URL(string: "http://127.0.0.1:11434")!)

    var chats: [ChatData] = []
    var conversations: [ChatData] = []
    
    var errorMessage: String?
    
    var bussy: Bool = false
    private var summarizationTask: Task<Void, any Error>?
    
    func pushChats(chats: [ChatData]) {
        self.chats = chats
    }
    
    func cancelSummarize() {
        if let task = summarizationTask {
            task.cancel()
            bussy = false
        } else {
            Logger.UILogger.warning("Summarization cancellation was initiated, but summarizationTask is nil")
        }
    }
    
    func sumarizeAll() {
        let task = Task {
            bussy = true
            for item in chats {
                let conversation = OllamaConversation(ollamaRemote: remote, model: .gemma31b, chatData: item)
                try await conversation.sumarize()
            }
            bussy = false
        }
        summarizationTask = task
    }
    // TODO: Rename OllamaConversation to OllamaDialog
    func makeDialog(chatData: ChatData) -> OllamaConversation {
        // Get model
        return OllamaConversation(ollamaRemote: remote, model: .gemma31b, chatData: chatData)
    }
}
