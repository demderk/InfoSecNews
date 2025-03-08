//
//  MainViewMode.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 25.02.2025.
//

import Foundation
import Combine

@Observable
class MainVM {
    
    var currentWindow: SelectedWindow = .home
    var secmed = NewsResolver(SecurityMediaModule())
    var seclab = SecurityLabRSSModule().preloaded()
    var antMal = AntiMalwareModule().preloaded()
    var voyager = WebVoyager()
    
    var storage: [any NewsBehavior] { secmed.newsCollection }
        
    var bussy: Bool = false
    
    func fetchContent() {
        Task {
            bussy = true
            await secmed.fetch()
            bussy = false
        }
    }
    
}
