//
//  MockNewsItem.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.05.2025.
//

import Foundation

class MockNewsItem: NewsBehavior {
    var source: String = "example.com"
    
    var title: String = "Белый дом запретит судам принимать иски против Белого дома"
    
    var date: Date = .now
    
    var short: String =
    // swiftlint:disable:next line_length
    "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."
    
    var fullTextLink: URL = URL(string: "example.com")!
    
    var full: String? =
    // swiftlint:disable:next line_length
    "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."
    
    func loadRemoteData(voyager: WebVoyager) async throws {
        print("Mock loadRemoteData initiated")
    }
}
