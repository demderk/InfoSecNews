//
//  OllamaRemote.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation
import os

class OllamaRemote {
    let remoteServerURL: URL = URL(string: "http://127.0.0.1:11434")!
    var selectedModel: MLModel
    
    init(selectedModel: MLModel) {
        self.selectedModel = selectedModel
    }
    
    func generateStream(
        prompt: String,
        system: String? = nil,
        onDataAppeared: @escaping (String) -> Void
    ) {
        let generationURL = remoteServerURL.appending(path: "/api/generate")
        
        var requestBody: [String: String] = [
            "model": selectedModel.name,
            "prompt": prompt
        ]
        
        if let system = system {
            requestBody["system"] = system
        }
        
        Task {
            let array = try! await readRemoteStream(streamURL: generationURL, jsonBody: requestBody, as: OllamaStreamResponse.self)
            
            do {
                
                for try await item in array {
                    onDataAppeared(item.response)
                }
            } catch {
                Logger.ollamaLogger.error("\(error.localizedDescription)")
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
    
    private func readRemoteStream(
        streamURL: URL,
        jsonBody: any Encodable
    ) async throws -> URLSession.AsyncBytes {
        var request = URLRequest(url: streamURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(jsonBody)
        
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
