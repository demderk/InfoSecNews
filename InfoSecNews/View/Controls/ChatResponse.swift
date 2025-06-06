//
//  ChatResponse.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 08.05.2025.
//

import os
import SwiftUI

struct ChatResponse: View {
    @Bindable var conversation: ChatData

    @Binding var isOriginal: Bool

    var roExpanded: Binding<Bool>?
    @State private var expanded: Bool

    private var newsIsExpanded: Binding<Bool> {
        roExpanded ?? .constant(false)
    }

    @State private var background: Color = .gray.opacity(0.05)
    @State private var foreground: Color = .primary
    @State private var buttonsBackground: Color = .white.opacity(0.3)

    @State private var newsText: String

    @State private var copyLinkImageName: String = "link"
    @State private var copyTextImageName: String = "document.on.document"
    @State private var expandNewsImageName: String

    /// ChatResponse
    /// - Parameters:
    ///     - roExpanded: Read-only Binding: external changes can update the card’s expanded state,
    /// but the card can’t modify the binding. It listens to updates but uses its own state.
    init(conversation: ChatData,
         isOriginal: Binding<Bool>,
         roExpanded: Binding<Bool>? = nil)
    {
        self.conversation = conversation
        _isOriginal = isOriginal
        self.roExpanded = roExpanded

        let expanded = roExpanded?.wrappedValue ?? false

        if expanded {
            newsText = conversation.news.short
            expandNewsImageName = "chevron.down"
        } else {
            newsText = conversation.UINewsContent
            expandNewsImageName = "chevron.up"
        }
        self.expanded = expanded
    }

    var onRefresh: (() -> Void)?
    var onChatOpen: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isOriginal ? conversation.news.title : "Summary")
                .font(.title3)
                .fontWeight(.semibold)
                .textSelection(.enabled)
                .transaction { $0.animation = nil }
            Text(isOriginal ? newsText : conversation.UISelectedContent)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .transaction { $0.animation = nil }
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

                if isOriginal {
                    makeMiniButton(imageSystemName: expandNewsImageName, action: {
                        changeExpandNewsMode(expand: !expanded)
                    })
                }
            }.padding(.top, 8)
        }
        .padding(16)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
        .onAppear(perform: viewAppeared)
        .onChange(of: isOriginal) {
            withAnimation(.easeOut(duration: 0.25)) {
                changeMode(isOriginal: isOriginal)
            }
        }
        .onChange(of: newsIsExpanded.wrappedValue) {
            changeExpandNewsMode(expand: newsIsExpanded.wrappedValue)
        }
    }

    private func viewAppeared() {
        changeMode(isOriginal: isOriginal)
//        changeExpandNewsMode(expand: newsIsExpanded.wrappedValue)
    }

    // TODO: This could be extracted into a separate ButtonStyle

    private func makeMiniButton(
        imageSystemName: String,
        action: @escaping () -> Void
    ) -> some View {
        let baseImage = Image(systemName: imageSystemName)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(buttonsBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .foregroundStyle(foreground.opacity(0.8))

        let baseButton = Button(action: action) {
            baseImage
        }.buttonStyle(.plain)

        if #available(macOS 15.0, *) {
            return baseButton.contentTransition(
                .symbolEffect(
                    .replace.magic(fallback: .downUp.byLayer),
                    options: .nonRepeating
                ))
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
        NSPasteboard.general.setString(conversation.news.fullTextLink.absoluteString, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            withAnimation {
                copyLinkImageName = "link"
            }
        }
    }

    private func copyText() {
        if let full = conversation.news.full {
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

    private func changeExpandNewsMode(expand: Bool) {
        withAnimation {
            if expand {
                newsText = conversation.news.short
                expandNewsImageName = "chevron.down"
            } else {
                newsText = conversation.UINewsContent
                expandNewsImageName = "chevron.up"
            }
            expanded = expand
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
    @Previewable @State var test = true

    VStack {
        Button("Change Mode") {
            test = !test
        }
        ChatResponse(conversation: MockChatData(), isOriginal: $test)
            .frame(height: 256)
    }
}
