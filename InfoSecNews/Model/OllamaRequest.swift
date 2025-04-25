//
//  OllamaRequest.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation

struct OllamaStreamResponse: Codable {
    var model: String
    // swiftlint:disable:next identifier_name
    var created_at: String
    var response: String
    var done: Bool
}

class OllamaStream: NSObject, URLSessionDataDelegate {
    private var buffer: Data = Data()
    
    var text: String = ""
    var finished = false
    var completeResponses: [OllamaStreamResponse]?
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.buffer.append(data)
        
        while let range = buffer.range(of: Data([0x0a])) {
            let streamText = buffer.subdata(in: 0..<range.lowerBound)
            buffer.removeSubrange(0...range.lowerBound)
            
            guard !streamText.isEmpty else { return }
            
            do {
                let decoded = try JSONDecoder().decode(OllamaStreamResponse.self, from: streamText)
                print(decoded)
                text += decoded.response
            } catch {
                print("JSON FAILED")
            }
        }
    }
    
    func start() async {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:11434/api/generate")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.setValue("application/x-ndjson", forHTTPHeaderField: "Accept")
        
        let body: [String: String] = [
            "model": "gemma3:1b",
            "prompt": "Привет!"
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        
        let (stream, _) = try! await URLSession.shared.bytes(for: request)
        
        do {
            for try await byte in stream.lines {
                print(byte)
            }
        } catch {
            
        }
    }
    
    func startStream(onURL: URL, body: [String: Any], onDataAppeared: ()) {
        var request = URLRequest(url: onURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        
        //        let (bytes, _) = URLSession.shared.bytes(for: URLRequest)
        
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        urlSession.dataTask(with: request).resume()
        
    }
}

enum MLModel {
    case gemma31b
    
    var remoteName: String {
        switch self {
        case .gemma31b:
            "gemma3:1b"
        }
    }
}

class OllamaRemote {
    let remoteServerURL: URL = URL(string: "http://127.0.0.1:11434")!
    
    let selectedModel: MLModel
    
    init(selectedModel: MLModel) {
        self.selectedModel = selectedModel
    }
    
    func generateStream(prompt: String, system: String? = nil, onDataAppeared: @escaping (String) -> Void) {
        let generationURL = remoteServerURL.appending(path: "/api/generate")
        
        var requestBody: [String: Any] = [
            "model": selectedModel.remoteName,
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
            let JSONObject = try JSONDecoder().decode(T.self, from: data)
            onJSONAppeared(JSONObject)
        }
    }
}
