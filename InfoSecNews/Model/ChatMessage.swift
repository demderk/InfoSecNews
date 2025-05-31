//
//  ChatMessage.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 02.05.2025.
//

import Foundation

@Observable
class ChatMessage: Identifiable, Equatable {
    var id = UUID()

    var role: MLRole
    var content: String

    init(_ base: MLMessage) {
        role = base.role
        content = base.content
    }

    init(role: MLRole, content: String) {
        self.role = role
        self.content = content
    }

    func asMLMessage() -> MLMessage {
        MLMessage(role: role, content: content)
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

enum MLConversationError: Error {
    case emptyNewsBody
}
