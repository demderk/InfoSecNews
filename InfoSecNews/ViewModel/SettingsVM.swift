//
//  SettingsVM.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 04.06.2025.
//

import Combine
import Foundation
import SwiftUI

@Observable
class SettingsVM {
    var wrongAttempts: Int = 0

    var systemMessage: String = ""
    var url: String = ""
    var status: String = "Disconnected"

    var remoteUpdated: PassthroughSubject<Void, Never> = .init()
    var messageUpdated: PassthroughSubject<Void, Never> = .init()
    private var cancellables: [AnyCancellable] = []

    init() {
        remoteUpdated
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink(receiveValue: { self.tryConnect(save: true) })
            .store(in: &cancellables)

        messageUpdated
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink(receiveValue: { self.saveSystemMessage() })
            .store(in: &cancellables)

        if let savedURL = readURL() {
            url = savedURL.absoluteString
            tryConnect()
        }

        if let message = readSystemMessage() {
            systemMessage = message
        }
    }

    func tryConnect(save: Bool = false) {
        if url.isEmpty {
            clearURL()
            status = "Disconnected"
            return
        }

        Task {
            do {
                guard let url = URL(string: url) else {
                    throw OllamaError.wrongURL
                }

                let remote = OllamaRemote(url: url)
                let version = try await remote.version()

                if save { saveURL(url: url) }
                status = "Connected to Ollama Server. Version: \(version)"
            } catch {
                withAnimation(.linear(duration: 0.35)) {
                    wrongAttempts += 1
                }
                switch error {
                case OllamaError.wrongURL:
                    status = "Wrong URL format"
                default:
                    status = "Connection failed"
                }
            }
        }
    }

    func saveURL(url: URL) {
        UserDefaults.standard.set(url.absoluteString, forKey: "serverURL")
    }

    func clearURL() {
        UserDefaults.standard.removeObject(forKey: "serverURL")
    }

    func readURL() -> URL? {
        guard let stringURL = UserDefaults.standard.string(forKey: "serverURL") else {
            return nil
        }
        return URL(string: stringURL)
    }

    func saveSystemMessage() {
        UserDefaults.standard.set(systemMessage, forKey: "systemMessage")
    }

    func clearSystemMessage() {
        UserDefaults.standard.removeObject(forKey: "systemMessage")
    }

    func readSystemMessage() -> String? {
        guard let message = UserDefaults.standard.string(forKey: "systemMessage") else {
            return nil
        }
        return message
    }
    
    func useDefaultSettings() {
        AppDefaults.setDefaultOlamaSettings()
        systemMessage = readSystemMessage() ?? ""
        url = readURL()?.absoluteString ?? ""
    }
}
