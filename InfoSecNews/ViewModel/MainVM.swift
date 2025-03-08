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
    var antMal = AntiMalwareModule().preloaded()
    var voyager = WebVoyager()
    
    var storage: [any NewsBehavior] {
        var x: [any NewsBehavior] = seclab.newsCollection + secmed.newsCollection
        x.sort(by: { $0.date > $1.date })
        return x
    }
    
    var bussy: Bool = false
    
    func fetchContent() {
        
        Task {
            bussy = true
            await seclab.fetch(pageCount: 3)
            await secmed.fetch()
            bussy = false
        }
    }
    
}
