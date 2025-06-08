//
//  AppLog.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.06.2025.
//

import os

class AppLog {
    static func error(_ message: String, location: String = #function) {
        Logger.appLog.error("[AppLog Error] [\(location)] \(message)")
    }

    static func warning(_ message: String, location: String = #function) {
        Logger.appLog.warning("[AppLog Warning] [\(location)] \(message)")
    }

    static func info(_ message: String, location: String = #function) {
        Logger.appLog.warning("[Info] [\(location)] \(message)")
    }
}
