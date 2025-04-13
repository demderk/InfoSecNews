//
//  NewsControl.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 23.02.2025.
//

import SwiftUI

struct NewsCard: View, Equatable {
    static func == (lhs: NewsCard, rhs: NewsCard) -> Bool {
        lhs.newsItem.title == rhs.newsItem.title
    }
    
    @State var newsItem: any NewsBehavior
    
    @State private var text: String
    @State private var hasFull: Bool = false
    @State private var buttonAngle: Double = 0
    @State private var opened: Bool = false
    @State private var textHeight: CGFloat = 0
    @State private var isLoading: Bool = false
    @State private var failed: Bool = false
    
    @State private var copyLinkImageName: String = "link"
    @State private var copyTextImageName: String = "document.on.document"
    
    let voyager: WebVoyager
    
    init(newsItem: any NewsBehavior, voyager: WebVoyager) {
        self.newsItem = newsItem
        self.hasFull = true
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
                            Spacer().frame(width: 16)
                        }.foregroundStyle(.secondary)
                            .padding([.bottom], 4)
                        HStack {
                            Text(newsItem.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                                .layoutPriority(1)
                        }
                        Spacer().frame(height: 8)
                    if opened {
                        Text(text)
                            .multilineTextAlignment(.leading)
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                            .textSelection(.enabled)
                            .transition(.opacity)
                            .layoutPriority(0)
                    } else {
                        Text(newsItem.short)
                            .multilineTextAlignment(.leading)
                            .font(.title3)
                            .textSelection(.enabled)
                            .multilineTextAlignment(.leading)
                            .frame(maxHeight: .infinity)
                            .transition(.opacity)
                            .animation(nil, value: newsItem.short)
                            .layoutPriority(0)
                    }
                }.frame(minWidth: 256, maxWidth: 896, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                Spacer()
                VStack(alignment: .trailing) {
                    if opened {
                    HStack(alignment: .center) {
                        Button(action: copyLink) {
                            if #available(macOS 15.0, *) {
                                Image(systemName: copyLinkImageName)
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .frame(width: 11, height: 11)
                                    .padding(4)
                                    .contentTransition(
                                        .symbolEffect(
                                            .replace.magic(fallback: .downUp.byLayer),
                                            options: .nonRepeating))
                            } else {
                                Image(systemName: copyLinkImageName)
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .frame(width: 11, height: 11)
                                    .padding(4)
                            }
                        }.buttonStyle(.plain)
                        Divider()
                            .frame(height: 16)
                            
                        Button(action: copyText) {
                            if #available(macOS 15.0, *) {
                                Image(systemName: copyTextImageName)
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .frame(width: 11, height: 11)
                                    .contentTransition(
                                        .symbolEffect(
                                            .replace.magic(fallback: .downUp.byLayer),
                                            options: .nonRepeating))
                                    .padding(4)
                            } else {
                                Image(systemName: copyTextImageName)
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .frame(width: 11, height: 11)
                                    .padding(4)
                            }
                        }.buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                    .background(.gray.opacity(0.03))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
                    .opacity(opened ? 1 : 0)
                        Spacer()
                    }
                    if hasFull {
                        Button(action: openFullText) {
                            ZStack {
                                Image(systemName: failed ? "xmark" : "chevron.down")
                                    .font(.system(size: 20, weight: .medium))
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
                        }
                            .buttonStyle(.plain)
                    }
                }.padding(32)
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
            Task {
                do {
                    try await newsItem.loadRemoteData(voyager: voyager)
                    let text = newsItem.full ?? "nope"
                    DispatchQueue.main.async {
                        self.text = text
                        withAnimation {
                            isLoading = false
                            buttonAngle = 180
                            opened = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        withAnimation {
                            isLoading = false
                            opened = false
                            failed = true
                        }
                        Task {
                            try? await Task.sleep(for: .seconds(3))
                            DispatchQueue.main.async {
                                withAnimation {
                                    failed = false
                                }
                            }
                        }
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
    
    func copyLink() {
        withAnimation {
            copyLinkImageName = "checkmark"
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(newsItem.fullTextLink.absoluteString, forType: .URL)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            withAnimation {
                copyLinkImageName = "link"
            }
        }
    }
    
    func copyText() {
        if let full = newsItem.full {
            withAnimation {
                copyTextImageName = "checkmark"
            }
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(full, forType: .string)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                withAnimation {
                    copyTextImageName = "document.on.document"
                }
            }
        }
    }
}

// swiftlint:disable line_length
#Preview {
    let mockNewsItem = SecurityLabNews(
        source: "debug.fm",
        title: "Белый дом запретит судам принимать иски против Белого дома",
        date: .now,
        short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
        full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
    VStack {
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
        NewsCard(newsItem: mockNewsItem, voyager: WebVoyager())
    }.frame(width: 1024)
        .background(.background)
}
// swiftlint:enable line_length
