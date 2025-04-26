//
//  NewsBehaviorDecorator.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 27.04.2025.
//

import Foundation

class NewsBehaviorDecorator: NewsBehavior {
    private let base: any NewsBehavior
    var id: UUID = UUID()
    
    init(baseBehavior: any NewsBehavior) {
        base = baseBehavior
    }
    
    var source: String { base.source }
    var title: String { base.title }
    var date: Date { base.date }
    var short: String { base.short }
    var fullTextLink: URL { base.fullTextLink }
    var full: String? { base.full }
    
    func loadRemoteData(voyager: WebVoyager) async throws {
        try await base.loadRemoteData(voyager: voyager)
    }
}


