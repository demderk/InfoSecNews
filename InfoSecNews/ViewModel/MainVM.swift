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
    var secmed = SecurityMediaNewsModule().preloaded()
    var seclab = SecurityLabRSSModule().preloaded()
    var voyager = WebVoyager()
    
    var storage: [any NewsBehavior] { seclab.newsCollection + secmed.newsCollection }
    
}
