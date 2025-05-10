////
////  ChatCardView.swift
////  InfoSecNews
////
////  Created by Roman Zheglov on 07.05.2025.
////
//
import SwiftUI
import Foundation

struct ChatCardView: View {
    @Bindable var conversation: OllamaConversation
    @State var isOrignalPresented: Bool
    @State var message: String = ""
    @FocusState var isFieldFocused: Bool
    
    var closeAction: (() -> Void)?
    
    var parentNameSpace: Namespace.ID
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
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
                            Button(action: {
                                action()
                            }) {
                                Image(systemName: "xmark")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                    .fontWeight(.semibold)
                                    .background(.gray.opacity(0.1))
                                    .foregroundStyle(.secondary)
                                    .clipShape(Circle())
                            }.buttonStyle(.plain)
                        }
                    }
                    ChatResponse(conversation: conversation,
                                 isOriginal: $isOrignalPresented)
                    .matchedGeometryEffect(id: conversation.id, in: parentNameSpace)
                }
                
                .padding(.top, 16)
                Text("Conversation started")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(16)
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
                        }
                    }
                }
            }.padding(.horizontal, 16)
            HStack(spacing: 8) {
                TextField("Message", text: $message, axis: .vertical)
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
                    .onSubmit(sendMessage)
                Button(action: sendMessage) {
                    Image(systemName: "paperplane")
                        .fontWeight(.semibold)
                        .font(.title3)
                        .contentShape(Rectangle())
                        .foregroundStyle(.secondary)
                }.buttonStyle(.plain)
            }.padding(16)
        }
    }
    
    private func sendMessage() {
        message = ""
        Task {
//            try! await conversation.sendMessage(prompt: message)
        }
    }
}

extension ChatCardView {
    func close(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.closeAction = action
        return copy
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
    @Previewable @Namespace var namespace
    
    ChatCardView(conversation: Omock(), isOrignalPresented: false, parentNameSpace: namespace)
        .frame(width: 600, height: 600)
        .background(.white)
}
