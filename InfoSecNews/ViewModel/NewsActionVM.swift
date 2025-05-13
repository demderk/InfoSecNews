//
//  NewsActionVM.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation
import os

import Foundation

@Observable
class NewsActionVM {
    let remote = OllamaRemote(selectedModel: .gemma31b)

    var selectedModeName: String = "prompt"
    var tts: String = "Привет!"
    var availableModels: [MLModel] = []

    var chats: [OllamaConversation] = []
    
    init() {
//        ollamaUpdateModels()
    }
    
    func ollamaUpdateModels() {
        Task {
            do {
                availableModels = try await remote.listModels()
            } catch {
                // swiftlint:disable:next line_length
                Logger.ollamaLogger.error("[NewsActionVM] (ollamaUpdateModels) raised an error. AvailableModels not updated. Description: \(error.localizedDescription)")
            }
        }
    }
    
    func ollamaPush(newsItems: [any NewsBehavior]) {
        guard selectedModeName != "prompt" else {
            Logger.ollamaLogger.debug("Push with prompt mode was initiated")
            return
        }
        
        Task {
            try! await chats.first!.sendMessage(prompt: tts)
        }
    }
    
    func initChats(news: [any NewsBehavior]) {
        for item in news {
            let ollamaConversation = OllamaConversation(ollamaRemote: remote, newsItem: item)
//            ollamaConversation.pull(role: .system, message: "Разговаривай только на русском языке, представь что ты Марио.")
            chats.append(ollamaConversation)
        }
    }
    
    func sumarizeAll() {
        Task {
            for item in chats {
                 try? await item.sumarize()
            }
        }
    }
}
