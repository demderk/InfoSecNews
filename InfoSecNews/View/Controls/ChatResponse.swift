//
//  ChatResponse.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 08.05.2025.
//

import SwiftUI
import os

struct ChatResponse: View {
    @Bindable var conversation: OllamaConversation
    
    @Binding var isOriginal: Bool
    
    @State private var background: Color = .gray.opacity(0.1)
    @State private var foreground: Color = .primary
    @State private var buttonsBackground: Color = .white.opacity(0.3)
    
    @State private var title: String = "No title"
    @State private var content: String = "No content"
    
    var onRefresh: (() -> Void)?
    var onChatOpen: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer().frame(height: 4)
                Text(content)
                HStack {
                    Button(action: {}) {
                        Image(systemName: "document.on.document")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(buttonsBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .foregroundStyle(foreground.opacity(0.8))
                    }.buttonStyle(.plain)
                    Spacer().frame(width: 4)
                    if let refreshAction = onRefresh {
                        Button(action: refreshAction) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(buttonsBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .foregroundStyle(foreground.opacity(0.8))
                        }.buttonStyle(.plain)
                        Spacer().frame(width: 4)
                    }
                    
                    if let chatAction = onChatOpen {
                        Button(action: chatAction) {
                            Image(systemName: "bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(buttonsBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .foregroundStyle(foreground.opacity(0.8))
                        }.buttonStyle(.plain)
                    }
                    Spacer()
                }
            }
            .padding(16)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
        }.onAppear {
            changeMode(isOriginal: isOriginal)
        }
        .onChange(of: isOriginal) {
            withAnimation(.easeOut(duration: 0.25)) {
                changeMode(isOriginal: isOriginal)
            }
        }
    }
    
    private func changeMode(isOriginal: Bool) {
        if isOriginal {
            background = .blue.opacity(0.85)
            foreground = .white
            buttonsBackground = .white.opacity(0.15)
            
            guard let news = conversation.newsItem else {
                Logger.UILogger.warning("ChatResponse without full article text was found. Using default values for title and content.")
                title = "No title"
                content = "No content"
                return
            }
            guard let full = news.full else {
                Logger.UILogger.warning("[ChatResponse] NewsItem with nil \"full\" was found. Using default value.")
                title = "No title"
                content = "No content"
                return
            }
            
            title = news.title
            content = full
        } else {
            background = .gray.opacity(0.1)
            foreground = .primary
            buttonsBackground = .white.opacity(0.3)
            title = "Summary"
            content = conversation.firstResponse
        }
        
    }
}

extension ChatResponse {
    func onChatOpen(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onChatOpen = action
        return copy
    }
    
    func onRefresh(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onRefresh = action
        return copy
    }
}

#Preview {
    @Previewable @State var test: Bool = true
    
    VStack {
        Button("x") {
            test = !test
        }
        ChatResponse(conversation: Omock(), isOriginal: $test)
    }
}
