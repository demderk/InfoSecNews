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
    var availableModels: [MLModel] = []
    var neuroNewsCollection: [NeuroNews] = []
    
    init() {
        ollamaUpdateModels()
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
        
        neuroNewsCollection.removeAll()
        
        for item in newsItems {
            guard let prompt = item.full else {
                Logger.ollamaLogger.debug("NewsItems contains objects where full == nil")
                return
            }
            
            let neuro = NeuroNews(baseBehavior: item, summary: "")
            neuro.summary = ""
            remote.generateStream(prompt: prompt, system: "Суммаризируй текст, в 2-3 предложения.") { text in
                neuro.summary += text
                print(neuro.summary)
                print(text)
            }
            neuroNewsCollection.append(neuro)
        }
    }
}
