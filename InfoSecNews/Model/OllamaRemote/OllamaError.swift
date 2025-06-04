//
//  OllamaError.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 04.06.2025.
//

import Foundation

enum OllamaError: Error {
    case emptyModel
    case missingModel
    case badRequest
    case wrongURL

    var localizedDescription: String {
        switch self {
        case .emptyModel:
            return "Empty model"
        case .missingModel:
            return "Model was not found in the ollama tags list"
        case .badRequest:
            return "Bad request"
        case .wrongURL:
            return "Wrong URL"
        }
    }
}
