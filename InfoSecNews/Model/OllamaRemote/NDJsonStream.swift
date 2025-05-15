//
//  NDJsonStream.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.05.2025.
//

import Foundation
import os

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
