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
    enum PresentedView {
        case chat(displaying: OllamaDialog)
        case conversations
        case none

        var presentTools: Bool {
            switch self {
            case .conversations:
                return true
            case .none, .chat:
                return false
            }
        }
    }

    private(set) var remote: OllamaRemote?

    var chats: [ChatData] = []
    var models: [MLModel] = []

    var executionAvailable: Bool = false
    var modelPopoverPresented: Bool = false
    var regenerateAlertPresented: Bool = false
    var serverAvailable: Bool = false

    private(set) var selectedModel: String = "No model available"
    var selectedMLModel: MLModel? {
        models.first(where: { $0.name == selectedModel })
    }

    var systemMessage: String {
        UserDefaults.standard.string(forKey: "systemMessage") ?? ""
    }

    var presentedView: PresentedView = .none
    var errorMessage: String?
    var showOriginals = true
    var extendedNews = true

    var bussy: Bool = false
    private var summarizationTask: Task<Void, Never>?

    init() {
        fetchModels()
    }

    func pushChats(chats: [ChatData]) {
        self.chats = chats
        if !chats.isEmpty {
            presentedView = .conversations
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
        showOriginals = false
        let task = Task {
            bussy = true
            for item in chats {
                do {
                    let conversation = try makeDialog(chatData: item)
                    try await conversation.sumarize(systemMessage: systemMessage)
                } catch {
                    errorMessage = error.localizedDescription
                    serverAvailable = false
                }
            }
            bussy = false
        }
        summarizationTask = task
    }

    func fetchModels() {
        if let savedURL = UserDefaults.standard.string(forKey: "serverURL"),
           let url = URL(string: savedURL)
        {
            remote = OllamaRemote(url: url)
        }

        guard let remote else {
            errorMessage = "No Ollama server URL configured"
            return
        }

        Task {
            do {
                models = try await remote.listModels()
            } catch {
                errorMessage = "Failed to connect ollama server"
                serverAvailable = false
                return
            }

            errorMessage = nil
            serverAvailable = true

            if let modelName = models.first?.name {
                if let savedModel = getSavedModelSelection(),
                   models.contains(where: { $0.name == savedModel })
                {
                    selectedModel = savedModel
                } else if !models.contains(where: { $0.name == selectedModel }) {
                    selectedModel = modelName
                }
                executionAvailable = true
            } else {
                executionAvailable = false
            }
        }
    }

    func makeDialog(chatData: ChatData) throws -> OllamaDialog {
        guard let model = selectedMLModel, let remote = remote else {
            throw OllamaError.missingModel
        }

        return OllamaDialog(ollamaRemote: remote, model: model, chatData: chatData)
    }

    func catchUIError<T1, Result>(throwable: (T1) throws -> Result, args: T1) -> Result? {
        do {
            return try throwable(args)
        } catch {
            Logger.UILogger.error("catchUIError encountered an error: \(error)")
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func presentChat(_ chatData: ChatData) {
        guard let dialog = catchUIError(throwable: makeDialog, args: chatData) else {
            return
        }
        presentedView = .chat(displaying: dialog)
    }

    func regenetateSummaries() {
        for item in chats {
            item.clearHistory()
        }
        sumarizeAll()
    }

    func saveModelSelection() {
        guard let selectedMLModel else {
            Logger.UILogger.error("Trying to write nil selectedMLModel to UserDefaults. Canceled.")
            return
        }
        UserDefaults.standard.set(selectedMLModel.name, forKey: "selectedModel")
    }

    func getSavedModelSelection() -> String? {
        if let savedModelName = UserDefaults.standard.string(forKey: "selectedModel") {
            return savedModelName
        }
        return nil
    }

    func setModel(model: MLModel) {
        selectedModel = model.name
        modelPopoverPresented = false
        saveModelSelection()
    }
}
