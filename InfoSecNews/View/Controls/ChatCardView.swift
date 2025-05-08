//
//  ChatCardView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.05.2025.
//

import SwiftUI

struct ChatCardView: View {
    @Namespace var ns
    
    @Bindable var conversation: OllamaConversation
    
    @State var originalIsPresented: Bool = false
    @State var bigMessageForeground: Color = .primary
    @State var bigMessageBackground: Color = .gray.opacity(0.15)
    @State var bigMessageButtonsBackground: Color = .white.opacity(0.3)
    
    @State var bigMessageTitle: String = "Response"
    @State var bigMessageContent: String = "Wait..."
    @State var message: String = "a"
    
    @State var extanded: Bool = false
    
    // БОЖЕ 🙏 ЭТО ТАКОЕ ГОВНО 💩 СПАСИ И СОХРАНИ 🙏🙏🙏🙏 БОЖЕ 🙏 ЭТО ТАКОЕ ГОВНО 💩 СПАСИ И СОХРАНИ 🙏🙏🙏🙏
    // БОЖЕ 🙏 ЭТО ТАКОЕ ГОВНО 💩 СПАСИ И СОХРАНИ 🙏🙏🙏🙏БОЖЕ 🙏 ЭТО ТАКОЕ ГОВНО 💩 СПАСИ И СОХРАНИ 🙏🙏🙏🙏
    // БОЖЕ 🙏 ЭТО ТАКОЕ ГОВНО 💩 СПАСИ И СОХРАНИ 🙏🙏🙏🙏 БОЖЕ 🙏 ЭТО ТАКОЕ ГОВНО 💩 СПАСИ И СОХРАНИ 🙏🙏🙏🙏
    // TODO: Rewrite code plz
    
    var body: some View {
        if extanded {
            VStack {
                ScrollView {
                    VStack() {
                        HStack {
                            HStack {
                                Button(action: {changeBigMessage(false)}) {
                                    Image(systemName: "quote.bubble")
                                        .padding(.vertical, 4)
                                        .padding(.leading, 16)
                                        .padding(.trailing, 16)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(originalIsPresented ? .gray : .blue)
                                }.buttonStyle(.plain)
                                Spacer().frame(width: 0)
                                Button(action: { changeBigMessage(true) }) {
                                    Image(systemName: "newspaper")
                                        .padding(.vertical, 8)
                                        .padding(.trailing, 16)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(originalIsPresented ? .blue : .gray)
                                }.buttonStyle(.plain)
                            }
                            .background(.gray.opacity(0.1))
                            .foregroundStyle(.secondary)
                            .clipShape(Capsule())
                            Spacer()
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        extanded = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                                        .fontWeight(.semibold)
                                }.buttonStyle(.plain)
                            }
                            .background(.gray.opacity(0.1))
                            .foregroundStyle(.secondary)
                            .clipShape(Capsule())
                        }
                        if (originalIsPresented) {
                            ChatResponse(title: $bigMessageTitle,
                                         content: $bigMessageContent,
                                         background: bigMessageBackground,
                                         foreground: bigMessageForeground,
                                         buttonsBackground: bigMessageButtonsBackground)
                        } else {
                            ChatResponse(title: $bigMessageTitle,
                                         content: $conversation.firstResponse,
                                         background: bigMessageBackground,
                                         foreground: bigMessageForeground,
                                         buttonsBackground: bigMessageButtonsBackground)
                            .matchedGeometryEffect(id: "12", in: ns)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 64)
                    VStack(alignment: .leading) {
                        ForEach(conversation.storage) { item in
                            HStack {
                                if item.role == .user {
                                    Spacer()
                                }
                                if item.role == .user {
                                    Text("\(item.content)")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .foregroundStyle(.white)
                                        .background(.blue)
                                        .clipShape(MessageBubble(isUserMessage: true))
                                        .padding(.leading, 128)
                                } else {
                                    Text("\(item.content)")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(.gray.opacity(0.2))
                                        .clipShape(MessageBubble(isUserMessage: false))
                                        .padding(.trailing, 128)
                                }
                            }.padding(.vertical, 4)
                            
                        }
                    }
                }.layoutPriority(10)
            }.onAppear() {
                bigMessageContent = conversation.firstResponse
            }
        } else {
            VStack {
                HStack {
                    HStack {
                        Button(action: {changeBigMessage(false)}) {
                            Image(systemName: "quote.bubble")
                                .padding(.vertical, 4)
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                                .fontWeight(.semibold)
                                .foregroundStyle(originalIsPresented ? .gray : .blue)
                        }.buttonStyle(.plain)
                        Spacer().frame(width: 0)
                        Button(action: { changeBigMessage(true) }) {
                            Image(systemName: "newspaper")
                                .padding(.vertical, 8)
                                .padding(.trailing, 16)
                                .fontWeight(.semibold)
                                .foregroundStyle(originalIsPresented ? .blue : .gray)
                        }.buttonStyle(.plain)
                    }
                    .background(.gray.opacity(0.1))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
                    Spacer()
                }
                ChatResponse(title: $bigMessageTitle,
                             content: $conversation.firstResponse,
                             background: bigMessageBackground,
                             foreground: bigMessageForeground,
                             buttonsBackground: bigMessageButtonsBackground)
                .onChatOpen {
                    withAnimation {
                        extanded = true
                    }
                }
                .matchedGeometryEffect(id: "12", in: ns)
            }
        }
    }
    
    private func changeBigMessage(_ presentOriginal: Bool) {
        withAnimation {
            if presentOriginal {
                originalIsPresented = true
                bigMessageForeground = .white
                bigMessageBackground = .blue
                bigMessageButtonsBackground = .gray.opacity(0.15)
                bigMessageTitle = conversation.newsItem?.title ?? "no news item"
                bigMessageContent = conversation.newsItem?.full ?? "no news item"
            } else {
                originalIsPresented = false
                bigMessageForeground = .primary
                bigMessageBackground = .gray.opacity(0.3)
                bigMessageButtonsBackground = .gray.opacity(0.3)
                bigMessageTitle = "Selected Response"
                bigMessageContent = conversation.firstResponse
            }
        }
    }
}

// swiftlint:disable line_length
class Omock: OllamaConversation {
    init() {
        let mockNewsItem = SecurityLabNews(
            source: "debug.fm",
            title: "Белый дом запретит судам принимать иски против Белого дома",
            date: .now,
            short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
            full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")
        super.init(ollamaRemote: OllamaRemote(
            selectedModel: .gemma31b),
                   newsItem: mockNewsItem)
        storage.append(ChatMessage(MLMessage(role: .assistant, content: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")))
        storage.append(ChatMessage(MLMessage(role: .user, content: "Почему белый дом, белый?")))
        storage.append(ChatMessage(MLMessage(role: .assistant, content: "хз...")))
    }
}
// swiftlint:enable line_length

#Preview {
    
    ChatCardView(conversation: Omock())
        .frame(width: 600, height: 600)
        .background(.white)
}
