//
//  LoggerExtensions.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 26.04.2025.
//
import os

extension Logger {
    static var ollamaLogger = Logger(subsystem: "com.zheglovco.InfoSecNews", category: "OllamaRemote")
    static var UILogger = Logger(subsystem: "com.zheglovco.InfoSecNews", category: "User Interface")
    static var appLog = Logger(subsystem: "com.zheglovco.InfoSecNews", category: "AppLog")
}
