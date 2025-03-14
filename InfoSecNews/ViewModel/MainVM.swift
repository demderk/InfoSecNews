//
//  MainViewMode.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 25.02.2025.
//

import Foundation
import Combine

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

@Observable
class MainVM {
    
    var currentWindow: SelectedWindow = .home
    var secmed = NewsResolver(SecurityMediaModule())
    var seclab = NewsResolver(SecurityLabModule())
    var antMal = NewsResolver(AntiMalwareModule())
    var voyager = WebVoyager()
    
    var storage: [any NewsBehavior] {
        var newsStorage: [any NewsBehavior] =
            secmed.newsCollection +
            seclab.newsCollection +
            antMal.newsCollection
        
        newsStorage.sort(by: { $0.date > $1.date })
        return newsStorage
    }
    
    var bussy: Bool = false
    
    func fetchContent() {
        Task {
            bussy = true
            await seclab.fetch(pageCount: 3)
            await secmed.fetch()
            await antMal.fetch(pageCount: 2)
            bussy = false
        }
    }
    
}
