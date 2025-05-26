//
//  NewsConversationView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 14.04.2025.
//

import SwiftUI

struct NewsConversationView: View {
    @Binding var chats: [ChatData]
    
    @State var vm: NewsConversationVM = NewsConversationVM()
    @State var showOriginals = true
    @State var extendedNews = true
    @State var selectedConversation: ChatData?
    
    @Namespace var animationNamespace
    
    private var hasItems: Bool {
        vm.chats.count > 0
    }
    
    var body: some View {
        ZStack {
            if hasItems {
                if let selected = selectedConversation {
                    fullscreenChat(conversation: vm.makeDialog(chatData: selected))
                }
                else {
                    conversationList
                }
            } else {
                nothing
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                tools
                    .opacity(hasItems ? 1 : 0)
                
            }
            ToolbarItem(placement: .primaryAction) {
                summarizationControl
            }
        }
        .onAppear {
            vm.pushChats(chats: chats)
        }
        
    }
    
    private var nothing: some View {
        VStack {
            Spacer()
            Text("No news selected")
                .font(.title)
                .foregroundStyle(.secondary)
            Spacer().frame(height: 8)
            Text("Pick a news from feed to get started")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.bottom, 64)
            Spacer()
        }
    }
    
    private func fullscreenChat(conversation: OllamaConversation) -> some View {
        ChatView(conversation: conversation,
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
    
    private var conversationList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack { Spacer() }
                ForEach(vm.chats) { item in
                    ChatResponse(
                        conversation: item,
                        isOriginal: $showOriginals,
                        roExpanded: $extendedNews
                    )
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
    
    private func toolButton(
        imageName: String,
        action: @escaping () -> Void,
        highlighted: Bool = false,
        imageScale: Image.Scale = .large
    ) -> some View {
        Button(action: action) {
            Image(systemName: imageName)
                .padding(.vertical, 8)
                .imageScale(imageScale)
                .padding(.horizontal, 8)
                .fontWeight(.medium)
                .foregroundStyle(highlighted ? .blue : .gray.opacity(0.8))
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
    
    private var tools: some View {
        HStack(spacing: 0) {
            toolButton(
                imageName: "quote.bubble",
                action: { showOriginals = false },
                highlighted: !showOriginals)
            Divider()
                .frame(height: 16)
            toolButton(
                imageName: "newspaper",
                action: { showOriginals = true },
                highlighted: showOriginals)
            if showOriginals {
                toolButton(
                    imageName: extendedNews
                        ? "arrow.up.and.line.horizontal.and.arrow.down"
                        : "arrow.down.and.line.horizontal.and.arrow.up",
                    action: { extendedNews = !extendedNews },
                    imageScale: .medium)
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var summarizationControl: some View {
        if vm.bussy {
            Button(action: {
                vm.cancelSummarize()
            }) {
                Image(systemName: "stop.fill")
                    .contentShape(Rectangle())
                    .padding(.horizontal, 8)
            }
            .opacity(selectedConversation == nil && vm.chats.count > 0
                     ? 1
                     : 0)
        } else {
            Button(action: {
                showOriginals = false
                vm.sumarizeAll()
            }) {
                Image(systemName: "play.fill")
                    .contentShape(Rectangle())
                    .padding(.horizontal, 8)
            }
            .opacity(selectedConversation == nil && vm.chats.count > 0
                     ? 1
                     : 0)
        }
    }
}

#Preview {
    @Previewable @State var mocks: [ChatData] = [
        MockChatData(),
        MockChatData(),
        MockChatData(),
        MockChatData(),
        MockChatData()
    ]
    NewsConversationView(chats: $mocks)
        .frame(width: 1000, height: 500)
}
