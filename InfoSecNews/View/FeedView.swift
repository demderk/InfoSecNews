//
//  HomeView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.03.2025.
//

import SwiftUI

struct FeedView: View {
    @Environment(MainVM.self) var parentViewModel
    
    var body: some View {
        VStack {
            Spacer().frame(height: 8)
            List {
                ForEach(parentViewModel.storage, id: \.id) { item in
                    EquatableView(content:
                        NewsCard(newsItem: item, voyager: parentViewModel.voyager))
                    .listRowSeparator(.hidden)
                    .id(item.id)
                }
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onAppear(perform: parentViewModel.fetchContent)
                        .opacity(0.9)
                        .scaleEffect(0.5)
                    Spacer()
                }
            }.listStyle(.plain)
            Spacer().frame(height: 8)
        }.navigationTitle("InfoSecNews → Feed")
    }
}
