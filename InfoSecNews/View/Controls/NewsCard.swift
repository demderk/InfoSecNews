//
//  NewsControl.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 23.02.2025.
//

import SwiftUI

struct NewsCard: View {
    @State var newsItem: NewsItem
    
    @State private var text: String
    @State private var hasFull: Bool = false
    @State private var buttonAngle: Double = 0
    @State private var opened: Bool = false
    @State private var textHeight: CGFloat = 0
    @State private var isLoading: Bool = false
    
    let voyager: WebVoyager
    
    init(newsItem: NewsItem, voyager: WebVoyager) {
        self.newsItem = newsItem
        self.hasFull = newsItem.fullParserStrategy != nil
        text = newsItem.short
        self.voyager = voyager
    }
    
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
                                .textSelection(.enabled)
                        }
                        Spacer().frame(height: 8)
                    if opened {
                        Text(text)
                            .multilineTextAlignment(.leading)
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                            .transition(
                                .asymmetric(
                                    insertion: AppearanceTransition().asAnyTransition,
                                    removal: .identity))
                    } else {
                        Text(newsItem.short)
                            .multilineTextAlignment(.leading)
                            .font(.title3)
                            .textSelection(.enabled)
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                            .transition(.opacity)
                            .animation(nil, value: newsItem.short)
                    }
                }.frame(minWidth: 256, maxWidth: 896, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                Spacer()
                if hasFull {
                    Button(action: openFullText) {
                        ZStack {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 24, weight: .medium))
                                .opacity(isLoading ? 0 : 1)
                            ProgressView().progressViewStyle(.circular)
                                .opacity(isLoading ? 0.9 : 0)
                                .scaleEffect(0.5)
                        }.foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.gray.opacity(0.03))
                            .rotationEffect(.degrees(buttonAngle))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }.padding(.trailing, 32)
                        .buttonStyle(.plain)
                }
            }
            .background(.background)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray.opacity(0.1), lineWidth: 2)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
    
    func openFullText() {
        if !opened {
            if let full = newsItem.full {
                self.text = full
                withAnimation {
                    buttonAngle = 180
                    opened = true
                }
                return
            }
            isLoading = true
            voyager.fetch(newsItem: newsItem) { result in
                let text = result.first?.full ?? self.text
                DispatchQueue.main.async {
                    self.text = text
                    withAnimation {
                        newsItem = result.first ?? newsItem
                        isLoading = false
                        buttonAngle = 180
                        opened = true
                    }
                }
            }
        } else {
            withAnimation {
                buttonAngle = 0
                opened = false
            }
        }
        
    }
}

// swiftlint:disable line_length
#Preview {
    let mockNewsItem = NewsItem(
        source: "debug.fm",
        title: "Белый дом запретит судам принимать иски против Белого дома",
        date: .now,
        short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!)
    VStack {
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
    }.frame(width: 1024)
        .background(.background)
}
// swiftlint:enable line_length
