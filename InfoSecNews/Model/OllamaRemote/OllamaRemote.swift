//
//  OllamaRemote.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation
import os

enum MLRole: String, Codable {
    case system
    case user
    case assistant
}

struct MLMessage: Codable {
    var role: MLRole
    var content: String
}

// BACKEND
struct MLChatRequest: Codable {
    var model: String // MLModel in future (model name)
    var messages: [MLMessage]
    // format
    // stream
}

// BACKEND
struct MLChatResponse: Codable {
    var message: MLMessage
    var done: Bool
}

class OllamaRemote {
    // TODO: Remove hardcoded creds
    let remoteServerURL: URL = URL(string: "http://127.0.0.1:11434")!
    var selectedModel: MLModel
    
    init(selectedModel: MLModel) {
        self.selectedModel = selectedModel
    }
    
    func generateStream(
        prompt: String,
        system: String? = nil
    ) async throws -> NDJsonStream<OllamaStreamResponse> {
        let generationURL = remoteServerURL.appending(path: "/api/generate")
        
        var requestBody: [String: String] = [
            "model": selectedModel.name,
            "prompt": prompt
        ]
        
        if let system = system {
            requestBody["system"] = system
        }
        
        let array = try await readRemoteStream(
            streamURL: generationURL,
            jsonBody: requestBody,
            as: OllamaStreamResponse.self)
        
        return array
    }
    
    func generateStream(
        prompt: String,
        system: String? = nil,
        onDataAppeared: @escaping (String) -> Void
    ) throws {
        Task {
            do {
                let array = try await generateStream(prompt: prompt, system: system)
                for try await item in array {
                    onDataAppeared(item.response)
                }
            } catch {
                Logger.ollamaLogger.error("\(error.localizedDescription)")
                throw error
            }
            
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
    
    func chatStream(
        chatRequest: MLChatRequest,
    ) async throws -> NDJsonStream<MLChatResponse> {
        let chatURL = remoteServerURL.appending(path: "/api/chat")
        
        let stream = try await readRemoteStream(
            streamURL: chatURL,
            jsonBody: chatRequest,
            as: MLChatResponse.self
        )
        return stream
    }
    
    private func readRemoteStream(
        streamURL: URL,
        jsonBody: any Encodable
    ) async throws -> URLSession.AsyncBytes {
        var request = URLRequest(url: streamURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        request.httpBody = try encoder.encode(jsonBody)
        
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        return stream
    }
    
    private func readRemoteStream<T: Decodable>(
        streamURL: URL,
        jsonBody: any Encodable,
        as: T.Type
    ) async throws -> NDJsonStream<T> {
        let byteStream = try await readRemoteStream(streamURL: streamURL, jsonBody: jsonBody)
        let ndjsonStream = NDJsonStream<T>(bytes: byteStream)
        return ndjsonStream
    }
}

struct NDJsonStream<T: Decodable>: AsyncSequence {
    typealias Element = T
    typealias AsyncIterator = NDJsonIterator
    
    let bytes: URLSession.AsyncBytes
    
    struct NDJsonIterator: AsyncIteratorProtocol {
        var iterator: URLSession.AsyncBytes.Iterator
        var buffer = Data()
        
        mutating func next() async throws -> Element? {
            while true {
                // FYI: data == 0x0A is newline
                if let jsonStrSubrange = buffer.firstRange(of: Data([0x0A])) {
                    let line = buffer.prefix(upTo: jsonStrSubrange.lowerBound)
                    buffer.removeSubrange(...jsonStrSubrange.lowerBound)
                    let decoder = JSONDecoder()
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    return try decoder.decode(T.self, from: line)
                }
                
                guard let next = try await iterator.next() else {
                    if !buffer.isEmpty {
                        let tail = String(data: buffer, encoding: .utf8)
                        Logger.ollamaLogger.info("Not null data. \(tail ?? "No tail")")
                    }
                    return nil
                }
                
                buffer.append(next)
            }
        }
    }
    
    func makeAsyncIterator() -> NDJsonIterator {
        return NDJsonIterator(iterator: bytes.makeAsyncIterator())
    }
}
