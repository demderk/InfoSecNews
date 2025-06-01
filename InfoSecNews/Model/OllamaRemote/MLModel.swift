//
//  MLModel.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation

struct MLModel: Codable, Identifiable, Equatable {
    var id: String { name }

    var name: String
    var alias: String?
    var details: MLModelDetails

    struct MLModelDetails: Codable {
        var family: String
        var parameterSize: String
    }

    static var wellKnownModels: [MLModel] {
        [.gemma31b, .gemma3, .llama3]
    }

    static func == (lhs: MLModel, rhs: MLModel) -> Bool {
        lhs.name == rhs.name
    }
}

extension MLModel {
    // MARK: Well-Known Recomended Models

    static let gemma31b: MLModel = .init(
        name: "gemma3:1b",
        alias: "Maximum Performance (Gemma 3:1b)",
        details: MLModelDetails(
            family: "gemma3",
            parameterSize: "999.89M"
        )
    )

    static let gemma3: MLModel = .init(
        name: "gemma3:latest",
        alias: "Better Performance (Gemma 3)",
        details: MLModelDetails(
            family: "gemma3",
            parameterSize: "4.3B"
        )
    )

    static let llama3: MLModel = .init(
        name: "llama3:8b",
        alias: "Better Quality (Llama 3)",
        details: MLModelDetails(
            family: "llama",
            parameterSize: "8.0B"
        )
    )
}
