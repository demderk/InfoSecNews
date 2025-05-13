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
    
    @State private var background: Color = .gray.opacity(0.05)
    @State private var foreground: Color = .primary
    @State private var buttonsBackground: Color = .white.opacity(0.3)
    
    @State private var copyLinkImageName: String = "link"
    @State private var copyTextImageName: String = "document.on.document"
    
    var onRefresh: (() -> Void)?
    var onChatOpen: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isOriginal ? conversation.newsItem.title: "Summary")
                .font(.title3)
                .fontWeight(.semibold)
                .textSelection(.enabled)
            Text(isOriginal ? conversation.newsContent : conversation.selectedContent)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            HStack(spacing: 4) {
                makeMiniButton(imageSystemName: copyTextImageName, action: copyText)
                makeMiniButton(imageSystemName: copyLinkImageName, action: copyLink)
                
                if let refreshAction = onRefresh {
                    makeMiniButton(imageSystemName: "arrow.clockwise", action: refreshAction)
                }
                if let chatAction = onChatOpen {
                    makeMiniButton(imageSystemName: "bubble", action: chatAction)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
        .onAppear { changeMode(isOriginal: isOriginal) }
        .onChange(of: isOriginal) {
            withAnimation(.easeOut(duration: 0.25)) {
                changeMode(isOriginal: isOriginal)
            }
        }
    }
    
    // TODO: This could be extracted into a separate ButtonStyle
    
    private func makeMiniButton(
        imageSystemName: String,
        action: @escaping () -> Void
    ) -> some View {
        let baseImage = Image(systemName: imageSystemName)
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(buttonsBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .foregroundStyle(foreground.opacity(0.8))
            
        let baseButton = Button(action: action) {
            baseImage
        }.buttonStyle(.plain)
        
        if #available(macOS 15.0, *) {
            return baseButton.contentTransition(
                .symbolEffect(
                    .replace.magic(fallback: .downUp.byLayer),
                    options: .nonRepeating))
        } else {
            return baseButton
        }
    }
    
    private func changeMode(isOriginal: Bool) {
        if isOriginal {
            background = .blue.opacity(0.85)
            foreground = .white
            buttonsBackground = .white.opacity(0.15)
        } else {
            background = .gray.opacity(0.05)
            foreground = .primary
            buttonsBackground = .white.opacity(0.3)
        }
        
    }
    
    private func copyLink() {
        withAnimation {
            copyLinkImageName = "checkmark"
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(conversation.newsItem.fullTextLink.absoluteString, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            withAnimation {
                copyLinkImageName = "link"
            }
        }
    }
    
    private func copyText() {
        if let full = conversation.newsItem.full {
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
        Button("Change Mode") {
            test = !test
        }
        ChatResponse(conversation: Omock(), isOriginal: $test)
            .frame(height: 256)
    }
}
