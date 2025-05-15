//
//  NewsActionVM.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation
import os

@Observable
class NewsActionVM {
    let remote = OllamaRemote(selectedModel: .gemma31b)

//    var availableModels: [MLModel] = []

    var chats: [OllamaConversation] = []
    
    var errorMessage: String?
    var summarizationTask: Task<Void, any Error>?
    var bussy: Bool = false
    
    init() {
//        ollamaUpdateModels()
    }
    
//    func ollamaUpdateModels() {
//        Task {
//            do {
//                availableModels = try await remote.listModels()
//            } catch {
//                // swiftlint:disable:next line_length
//                Logger.ollamaLogger.error("[NewsActionVM] (ollamaUpdateModels) raised an error. AvailableModels not updated. Description: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func initChats(news: [any NewsBehavior]) {
        for item in news {
            let ollamaConversation = OllamaConversation(ollamaRemote: remote, newsItem: item)
//            ollamaConversation.pull(role: .system, message: "Разговаривай только на русском языке, представь что ты Марио.")
            chats.append(ollamaConversation)
        }
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
                 try await item.sumarize()
            }
            bussy = false
        }
        summarizationTask = task
    }
}
