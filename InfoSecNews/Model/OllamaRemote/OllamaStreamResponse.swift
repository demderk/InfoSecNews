//
//  OllamaStreamResponse.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation

struct OllamaStreamResponse: Codable {
    var model: String
    var createdAt: String
    var response: String
    var done: Bool
}
