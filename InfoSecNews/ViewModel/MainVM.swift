//
//  MainVM.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import Foundation

class MainVM: ObservableObject {
    @Published var text: String = ""
    
    func processSites() {
        let parser = NewsParser()
        Task {
            await parser.getNews()
        }
    }
}
