//
//  InfoSecNewsApp.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}

@main
struct InfoSecNewsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            VStack {
                MainView()
                    .frame(minWidth: 640, minHeight: 420)
            }
        }
    }
}
