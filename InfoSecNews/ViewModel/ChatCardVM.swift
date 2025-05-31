//
//  ChatCardVM.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.05.2025.
//

import Foundation
import os

@Observable
class ChatCardVM {
    var message: String = ""
    var bussy: Bool = false

    private var sendTask: Task<Void, any Error>?

    func sendMessage(conversation: OllamaDialog) {
        let task = Task { [message] in
            bussy = true
            try await conversation.sendMessage(prompt: message)
            bussy = false
        }
        message = ""
        sendTask = task
    }

    func cancel() {
        if let task = sendTask {
            task.cancel()
            bussy = false
        } else {
            Logger.UILogger.warning("Send cancellation was initiated, but sendTask is nil")
        }
    }
}
