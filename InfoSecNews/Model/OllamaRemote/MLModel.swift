//
//  MLModel.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//

import Foundation

struct MLModel: Codable, Identifiable {
    var id: String { name }

    var name: String
    var details: MLModelDetails

    struct MLModelDetails: Codable {
        var family: String
        var parameterSize: String
    }

    static let gemma31b: MLModel = .init(
        name: "gemma3:1b",
        details: MLModelDetails(
            family: "gemma3",
            parameterSize: "999.89M"
        )
    )
}
