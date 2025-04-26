//
//  NeuroNews.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 27.04.2025.
//

import Foundation

@Observable
class NeuroNews: NewsBehaviorDecorator {
    var summary: String = ""

    init(baseBehavior: any NewsBehavior, summary: String) {
        super.init(baseBehavior: baseBehavior)
        self.summary = summary
    }
}
