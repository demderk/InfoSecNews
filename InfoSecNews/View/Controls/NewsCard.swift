//
//  NewsControl.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 23.02.2025.
//

import SwiftUI

struct NewsCard: View {
    let newsItem: NewsItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Image(systemName: "calendar")
                        .fontWeight(.semibold)
                    Spacer().frame(width: 4)
                    Text(newsItem.date.formatted(date: .complete, time: .omitted))
                    Spacer().frame(width: 16)
                    Image(systemName: "newspaper")
                        .fontWeight(.semibold)
                    Spacer().frame(width: 4)
                    Text(newsItem.source)
                }.foregroundStyle(.secondary)
                    .padding([.bottom], 4)
                HStack {
                    Text(newsItem.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                }
                Spacer().frame(height: 8)
                Text(newsItem.short)
                    .font(.title3)
                    .lineLimit(2)
                    .frame(minHeight: 48, alignment: .topLeading)
                    .multilineTextAlignment(.leading)
            }.frame(minWidth: 256, maxWidth: 896, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            Spacer()
        }
        .background(.background)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray.opacity(0.1), lineWidth: 2)
        )
//        .shadow(color: .gray.opacity(0.1), radius: 10, x: 2, y: 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// swiftlint:disable line_length
#Preview {
    let mockNewsItem = NewsItem(
        source: "debug.fm",
        title: "Белый дом запретит судам принимать иски против Белого дома",
        date: .now,
        short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
    VStack {
        NewsCard(newsItem: mockNewsItem)
        NewsCard(newsItem: mockNewsItem)
        NewsCard(newsItem: mockNewsItem)
        NewsCard(newsItem: mockNewsItem)
    }.frame(width: 1024)
        .background(.background)
}
// swiftlint:enable line_length
