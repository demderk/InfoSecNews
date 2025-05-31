//
//  MainViewSelectedDetail.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 29.05.2025.
//

import Foundation

enum MainViewSelectedDetail: CaseIterable, Identifiable {
    var id: Self { self }

    case home
    case conversations
    case securityMedia
    case securityLab
    case antiMalware
    case voyager

    var title: String {
        switch self {
        case .home:
            "Feed"
        case .securityMedia:
            "SecurityMedia"
        case .securityLab:
            "SecurityLab"
        case .antiMalware:
            "Anti-Malware"
        case .voyager:
            "Web Voyager"
        case .conversations:
            "Conversations"
        }
    }

    var imageString: String {
        switch self {
        case .home:
            "dot.radiowaves.up.forward"
        case .securityMedia, .antiMalware, .securityLab:
            "network"
        case .voyager:
            "location.square"
        case .conversations:
            "bubble.left.and.bubble.right"
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .conversations: 11
        default: 15
        }
    }

    var asEnabledModule: EnabledModules? {
        switch self {
        case .securityMedia:
            EnabledModules.securityMedia
        case .securityLab:
            EnabledModules.securityLab
        case .antiMalware:
            EnabledModules.antiMalware
        default: nil
        }
    }

    static var groups: [(name: String, items: [MainViewSelectedDetail])] {
        [
            ("Tools", [.home, .conversations]),
            ("News Sources", [.securityMedia, .securityLab, .antiMalware]),
            ("Misc", [.voyager]),
        ]
    }
}
