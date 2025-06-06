//
//  AppLog.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.06.2025.
//

import os

class AppLog {
    static func error(message: String, location: String = #function) {
        Logger.appLog.error("[AppLog Error] [\(location)] \(message)")
    }
    
    static func warning(location: String, message: String) {
        Logger.appLog.warning("[AppLog Warning] [\(location)] \(message)")
    }
}
