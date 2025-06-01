////
////  ChatCardView.swift
////  InfoSecNews
////
////  Created by Roman Zheglov on 07.05.2025.
////
//
import Foundation
import SwiftUI

struct ChatView: View {
    @Bindable var conversation: OllamaDialog
    @Bindable var vm: ChatCardVM = .init()
    @State var isOrignalPresented: Bool

    @FocusState var isFieldFocused: Bool

    var closeAction: (() -> Void)?

    var parentNameSpace: Namespace.ID

    var responseHeader: some View {
        HStack {
            HStack(spacing: 0) {
                Button(action: { isOrignalPresented = false }) {
                    Image(systemName: "quote.bubble")
                        .padding(.vertical, 8)
                        .padding(.leading, 8)
                        .padding(.horizontal, 8)
                        .fontWeight(.semibold)
                        .foregroundStyle(isOrignalPresented ? .gray : .blue)
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
                Button(action: { isOrignalPresented = true }) {
                    Image(systemName: "newspaper")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .padding(.trailing, 8)
                        .fontWeight(.semibold)
                        .foregroundStyle(isOrignalPresented ? .blue : .gray)
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
            .background(.gray.opacity(0.1))
            .clipShape(Capsule())
            Spacer()
            if let action = closeAction {
                Button(
                    action: {
                        action()
                    }
                ) {
                    Image(systemName: "xmark")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .fontWeight(.semibold)
                        .background(.gray.opacity(0.1))
                        .foregroundStyle(.secondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    func makeChatBody(scrollProxy proxy: ScrollViewProxy, scrollTo: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(conversation.storage.filter { $0.role != .system }) { item in
                chatBubble(item)
                    .onChange(of: item.content) {
                        proxy.scrollTo(scrollTo, anchor: .bottom)
                    }
            }
        }
    }

    func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            let isUser = message.role == .user
            if isUser {
                Spacer()
            }
            let body = Text(message.content)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isUser ? Color.blue : .gray.opacity(0.1))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(MessageBubble(isUserMessage: isUser))
                .textSelection(.enabled)

            if isUser {
                body
                    .padding(.leading, 128)
            } else {
                body
            }

            if !isUser {
                Button(
                    action: {
                        makeFavorite(message: message)
                    }
                ) {
                    Image(systemName: conversation.chatData.selectedMessage == message ? "star.fill" : "star")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .fontWeight(.semibold)
                        .background(.gray.opacity(0.1))
                        .foregroundStyle(.secondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 128)
            }
        }
    }

    var chatField: some View {
        HStack(spacing: 8) {
            TextField("Message", text: $vm.message, axis: .vertical)
                .lineLimit(5)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.gray.opacity(0.4), lineWidth: 1)
                }
                .contentShape(Capsule(style: .continuous))
                .focused($isFieldFocused)
                .textFieldStyle(.plain)
                .onTapGesture {
                    isFieldFocused = !isFieldFocused
                }
                .onSubmit(send)
            if vm.bussy {
                Button(action: cancel) {
                    Image(systemName: "stop.fill")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .contentShape(Rectangle())
                        .foregroundStyle(.secondary)
                }.buttonStyle(.plain)
            } else {
                Button(action: send) {
                    Image(systemName: "paperplane")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .contentShape(Rectangle())
                        .foregroundStyle(.secondary)
                }.buttonStyle(.plain)
            }
        }
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        responseHeader
                        ChatResponse(conversation: conversation.chatData,
                                     isOriginal: $isOrignalPresented)
                            .matchedGeometryEffect(id: conversation.id, in: parentNameSpace)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    Text("Conversation started")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(16)
                    makeChatBody(scrollProxy: proxy, scrollTo: "CHAT_BOTTOM")
                        .padding(.horizontal, 16)
                        .padding(.bottom, 64)
                    Color.clear.id("CHAT_BOTTOM")
                    Spacer()
                }
            }
            VStack {
                Spacer()
                chatField
                    .padding(16)
                    .background(
                        Color.white.opacity(0.8)
                            .background(.thinMaterial)
                    )
            }
        }
    }

    private func send() {
        vm.sendMessage(conversation: conversation)
    }

    private func cancel() {
        vm.cancel()
    }

    private func makeFavorite(message: ChatMessage) {
        conversation.setSelectedMessage(message)
    }
}

extension ChatView {
    func close(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.closeAction = action
        return copy
    }
}

#Preview {
    @Previewable @Namespace var namespace

    ChatView(conversation: MockOllamaConversation(), isOrignalPresented: false, parentNameSpace: namespace)
        .frame(width: 600, height: 600)
        .background(.white)
}
