//
//  HomeView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 19.02.2025.
//

import SwiftUI

struct HomeView: View {
    var modules: [String]
    
    var body: some View {
        VStack {
            ForEach(modules, id: \.self) { item in
                
            }
        }
    }
}

#Preview {
    HomeView(modules: [""])
}
