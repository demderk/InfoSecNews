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

    var selectedMode: String = "prompt"
    var text: String = ""
    var availableModels: [MLModel] = []
    
    init() {
        ollamaUpdateModels()
    }
    
    func ollamaUpdateModels() {
        Task {
            do {
                availableModels = try await remote.listModels()
            } catch {
                Logger.ollamaLogger.error("[NewsActionVM] (ollamaUpdateModels) raised an error. AvailableModels not updated. Description: \(error.localizedDescription)")
            }
        }
    }
    
    func ollamaPush() {
        Task {
            availableModels = (try? await remote.listModels()) ?? availableModels
        }
//        guard let item = newsItems.first, let text = item.full else { return }
//        remote.generateStream(prompt: text, system: "Суммаризируй текст, в 2-3 предложения.") { text in
//            self.text += text
//        }
    }
}
