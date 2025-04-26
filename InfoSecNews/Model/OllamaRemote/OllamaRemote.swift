//
//  OllamaRemote.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation

class OllamaRemote {
    let remoteServerURL: URL = URL(string: "http://127.0.0.1:11434")!
    var selectedModel: MLModel
    
    init(selectedModel: MLModel) {
        self.selectedModel = selectedModel
    }
    
    func generateStream(prompt: String, system: String? = nil, onDataAppeared: @escaping (String) -> Void) {
        let generationURL = remoteServerURL.appending(path: "/api/generate")
        
        var requestBody: [String: Any] = [
            "model": selectedModel.name,
            "prompt": prompt
        ]
        
        if let system = system {
            requestBody["system"] = system
        }
        
        Task {
            try! await readRemoteStream(
                onURL: generationURL,
                body: requestBody,
                onJSONAppeared: { (response: OllamaStreamResponse) in
                    onDataAppeared(response.response)
                }
            )
        }
    }
    
    func listModels() async throws -> [MLModel] {
        let listURL = remoteServerURL.appending(path: "/api/tags")
        var request = URLRequest(url: listURL)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let decoded = try decoder.decode([String: [MLModel]].self, from: data)
        
        if let models = decoded["models"] {
            return models
        }
        return []
    }
    
    private func readRemoteStream(
        onURL: URL,
        body: [String: Any],
        onLineAppeared: @escaping (String) -> Void
    ) async throws {
        var request = URLRequest(url: onURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        for try await byte in stream.lines {
            onLineAppeared(byte)
        }
    }
    
    private func readRemoteStream<T: Decodable>(
        onURL: URL,
        body: [String: Any],
        onJSONAppeared: @escaping (T) -> Void
    ) async throws {
        var request = URLRequest(url: onURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        for try await byte in stream.lines {
            guard let data = byte.data(using: .utf8) else { continue }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let JSONObject = try decoder.decode(T.self, from: data)
            onJSONAppeared(JSONObject)
        }
    }
}
