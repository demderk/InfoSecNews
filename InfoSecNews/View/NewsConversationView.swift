//
//  NewsConversationView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 14.04.2025.
//

import SwiftUI

struct NewsConversationView: View {
    @Binding var newsItems: [any NewsBehavior]
    
    @State var vm: NewsActionVM = NewsActionVM()
    @State var showOriginals = true
    @State var selectedConversation: OllamaConversation?
    
    @Namespace var animationNamespace
    
    var body: some View {
        ZStack {
            if let selected = selectedConversation {
                ChatCardView(conversation: selected,
                             isOrignalPresented: showOriginals,
                             parentNameSpace: animationNamespace)
                .close {
                    withAnimation(.bouncy(duration: 0.35)) {
                        selectedConversation = nil
                    }
                }
                .opacity(selectedConversation == nil ? 0 : 1)
                .background(.background)
            }
            else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack { Spacer() }
                        ForEach(vm.chats) { item in
                            ChatResponse(conversation: item, isOriginal: $showOriginals)
                                .onChatOpen {
                                    withAnimation(.bouncy(duration: 0.35)) {
                                        selectedConversation = item
                                    }
                                }.matchedGeometryEffect(id: item.id, in: animationNamespace)
                        }
                    }
                    .padding(.vertical, 0)
                    .padding(.horizontal, 16)
                }
                .opacity(selectedConversation == nil ? 1 : 0)
                .background(.background)
            }
        }
        .layoutPriority(1)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 0) {
                    Button(action: { showOriginals = false }) {
                        Image(systemName: "quote.bubble")
                            .padding(.vertical, 8)
                            .padding(.leading, 8)
                            .imageScale(.large)
                            .padding(.horizontal, 8)
                            .fontWeight(.medium)
                            .foregroundStyle(showOriginals ? Color.secondary : .blue)
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Divider()
                        .frame(height: 16)
                    Button(action: { showOriginals = true }) {
                        Image(systemName: "newspaper")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            .padding(.trailing, 8)
                            .imageScale(.large)
                            .fontWeight(.medium)
                            .foregroundStyle(showOriginals ? .blue : .secondary)
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
                .padding(.trailing, 8)
                .opacity(selectedConversation == nil ? 1 : 0)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showOriginals = false
                    vm.sumarizeAll()
                }) {
                    Image(systemName: "play.fill")                        .contentShape(Rectangle())
                        .padding(.horizontal, 8)
                }
                .opacity(selectedConversation == nil ? 1 : 0)
            }
        }
        .onAppear {
            vm.initChats(news: newsItems)
        }
    }
}

// swiftlint:disable line_length
#Preview {
    // AXAXAXAXA
    @Previewable @State var mocks: [any NewsBehavior] = [SecurityLabNews(
        source: "debug.fm",
        title: "Белый дом запретит судам принимать иски против Белого дома",
        date: .now,
        short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
        full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."), SecurityLabNews(
            source: "debug.fm",
            title: "Белый дом запретит судам принимать иски против Белого дома",
            date: .now,
            short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
            full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."), SecurityLabNews(
                source: "debug.fm",
                title: "Белый дом запретит судам принимать иски против Белого дома",
                date: .now,
                short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
                full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."), SecurityLabNews(
                    source: "debug.fm",
                    title: "Белый дом запретит судам принимать иски против Белого дома",
                    date: .now,
                    short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
                    full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")]
    NewsConversationView(newsItems: $mocks)
        .frame(width: 1000, height: 500)
}
// swiftlint:enable line_length
