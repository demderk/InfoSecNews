//
//  MainViewMode.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 25.02.2025.
//

import Foundation
import Combine

@Observable
class FeedVM {
    private let UDSelectedModulesName = "selectedModules"
    
    var enabledModules: EnabledModules = []
    
    var daysToFetch = 2
    private(set) var daysFetched: [EnabledModules: Int] = [:]
    private var maxFetchedDay: Int { daysFetched.values.max() ?? 0 }
    
    var secmed = NewsResolver(SecurityMediaModule())
    var seclab = NewsResolver(SecurityLabModule())
    var antMal = NewsResolver(AntiMalwareModule())
    var voyager = WebVoyager()
    
    var currentWindow: SelectedWindow = .home
    var bussy: Bool = false
    var chats: [ChatData] = []
    
    init() {
        let preferences = UserDefaults.standard
        if let raw = preferences.object(forKey: UDSelectedModulesName) as? Int {
            enabledModules = EnabledModules(rawValue: raw)
        }
    }
    
    var storage: [any NewsBehavior] {
        var newsStorage: [any NewsBehavior] = []
        
        if enabledModules.contains(.securityLab) {
            newsStorage += seclab.newsCollection
        }
        if enabledModules.contains(.securityMedia) {
            newsStorage += secmed.newsCollection
        }
        if enabledModules.contains(.antiMalware) {
            newsStorage += antMal.newsCollection
        }
        
        newsStorage.sort(by: { $0.date > $1.date })
        return newsStorage
    }
    
    func fetchTask(_ forModule: EnabledModules, daysToFetch: Int = 2) async {
        switch forModule {
        case .antiMalware:
            await antMal.fetch(daysAgo: daysToFetch)
        case .securityLab:
            await seclab.fetch(daysAgo: daysToFetch)
        case .securityMedia:
            await secmed.fetch(daysAgo: daysToFetch)
        default:
            print("[FetchTask] Unknown method. Aborting")
            return
        }
        daysFetched[forModule] = (daysFetched[forModule] ?? 0) + daysToFetch
        
    }
    
    // For UI purposes
    func spinnerAppear() {
        if !bussy {
            fetchContent()
        }
    }
    
    func fetchContent() {
        let days = daysToFetch
        Task {
            bussy = true
            await withTaskGroup(of: Void.self) { group in
                if enabledModules.contains(.securityLab) {
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        await fetchTask(.securityLab, daysToFetch: days)
                    }
                }
                if enabledModules.contains(.securityMedia) {
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        await fetchTask(.securityMedia, daysToFetch: days)

                    }
                }
                
                if enabledModules.contains(.antiMalware) {
                    group.addTask { [weak self] in
                        guard let self = self else { return }
                        await fetchTask(.antiMalware, daysToFetch: days)
                    }
                }
            }
            bussy = false
        }
    }
    
    func syncModules() {
        Task {
            bussy = true
            await withTaskGroup(of: Void.self) { group in
                for module in EnabledModules.allCases {
                    guard enabledModules.contains(module) else { continue }
                    let days = daysFetched[module] ?? 0
                    let diff = maxFetchedDay - days
                    if diff > 0 {
                        group.addTask { [weak self] in
                            guard let self = self else { return }
                            await fetchTask(module, daysToFetch: diff)
                        }
                    }
                }
            }
            bussy = false
        }
    }
    
    func saveSelectedModules() {
           let preferences = UserDefaults.standard
           preferences.set(self.enabledModules.rawValue, forKey: UDSelectedModulesName)
    }
    
    func createChat(news: any NewsBehavior) {
        chats.append(ChatData(news: news, messageHistory: []))
    }
    
    func removeChat(news: any NewsBehavior) {
        chats.removeAll(where: { $0.news.equals(news: news) })
    }
    
    func hasChat(news: any NewsBehavior) -> Bool {
        return chats.contains(where: { $0.news.equals(news: news) })
    }
}
