//
//  NewsConversationView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 14.04.2025.
//

import SwiftUI

struct NewsConversationView: View {
    @Binding var chats: [ChatData]

    @State var vm: NewsConversationVM = .init()

    @Namespace var animationNamespace

    var body: some View {
        ZStack {
            switch vm.presentedView {
            case let .chat(conversation):
                fullscreenChat(conversation: conversation)
            case .conversations:
                conversationList
            case .none:
                nothing
            }
        }
        .navigationTitle("")
        .confirmationDialog("Regenerate from Scratch", isPresented: $vm.regenerateAlertPresented) {
            Button("Regenerate", role: .destructive) { vm.regenetateSummaries() }
            Button("Cancel", role: .cancel) { vm.regenerateAlertPresented = false }
        } message: {
            Text("""
            This will delete all existing summaries and regenerate \
            them from scratch using the selected model.
            """)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                tools
                    .opacity(vm.presentedView.presentTools ? 1 : 0)
            }
            ToolbarItem(placement: .secondaryAction) {
                modelSelection
                    .opacity(vm.presentedView.presentTools ? 1 : 0)
            }
            ToolbarItem(placement: .primaryAction) {
                generationTools
                    .opacity(vm.presentedView.presentTools ? 1 : 0)
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

    private func fullscreenChat(conversation: OllamaDialog) -> some View {
        ChatView(
            conversation: conversation,
            isOrignalPresented: vm.showOriginals,
            parentNameSpace: animationNamespace
        )
        .close {
            withAnimation(.bouncy(duration: 0.35)) {
                vm.presentedView = .conversations
            }
        }
        .background(.background)
    }

    private var conversationList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack { Spacer() }
                ForEach(vm.chats) { item in
                    ChatResponse(
                        conversation: item,
                        isOriginal: $vm.showOriginals,
                        roExpanded: $vm.extendedNews
                    )
                    .onChatOpen {
                        withAnimation(.bouncy(duration: 0.35)) {
                            vm.presentChat(item)
                        }
                    }.matchedGeometryEffect(id: item.id, in: animationNamespace)
                }
            }
            .padding(.vertical, 0)
            .padding(.horizontal, 16)
        }
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
                .foregroundStyle(highlighted ? Color.accentColor : .gray.opacity(0.8))
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }

    private var tools: some View {
        HStack(spacing: 0) {
            toolButton(
                imageName: "quote.bubble",
                action: { vm.showOriginals = false },
                highlighted: !vm.showOriginals
            )
            Divider()
                .frame(height: 16)
            toolButton(
                imageName: "newspaper",
                action: { vm.showOriginals = true },
                highlighted: vm.showOriginals
            )
            if vm.showOriginals {
                toolButton(
                    imageName: vm.extendedNews
                        ? "arrow.up.and.line.horizontal.and.arrow.down"
                        : "arrow.down.and.line.horizontal.and.arrow.up",
                    action: { vm.extendedNews = !vm.extendedNews },
                    imageScale: .medium
                )
                .padding(.horizontal, 4)
            }
        }
    }

    private var modelSelection: some View {
        HStack {
            Button(action: {
                vm.modelPopoverPresented = true
            }) {
                if vm.models.isEmpty {
                    Text("Models not installed")
                        .frame(minWidth: 256)
                } else {
                    Text(
                        vm.selectedMLModel?.alias
                            ?? vm.selectedMLModel?.name
                            ?? "Select a model"
                    )
                    .frame(minWidth: 256)
                }
            }
            .disabled(vm.models.isEmpty)
            .popover(isPresented: $vm.modelPopoverPresented, arrowEdge: .bottom) {
                modelSelectionPicker
            }
            Button(action: vm.fetchModels) {
                Image(systemName: "arrow.down.to.line.compact")
                    .imageScale(.medium)
            }.help("Fetch models")
        }
    }

    private var modelSelectionPicker: some View {
        VStack {
            HStack {
                Text("Recomended Models")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .padding(.leading, 4)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(vm.models.filter({ $0.alias != nil })) { item in
                    ModelPickerButton(
                        isSelected: .constant(item.name == vm.selectedModel),
                        content: {
                            HStack {
                                Text(item.alias ?? item.name)
                                Spacer()
                            }
                        },
                        action: {
                            vm.selectedModel = item.name
                            vm.modelPopoverPresented = false
                        }
                    )
                }
            }
            HStack {
                Text("Available Models")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .padding(.leading, 4)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(vm.models.filter({ $0.alias == nil })) { item in
                    ModelPickerButton(
                        isSelected: .constant(item.name == vm.selectedModel),
                        content: {
                            HStack {
                                Text(item.alias ?? item.name)
                                Spacer()
                            }
                        },
                        action: {
                            vm.selectedModel = item.name
                            vm.modelPopoverPresented = false
                        }
                    )
                }
            }
        }.padding(8)
            .frame(minWidth: 256)
    }

    private var generationTools: some View {
        HStack(spacing: 0) {
            regenerateAll
            summarizeButton
        }
    }

    private var regenerateAll: some View {
        Button(
            action: { vm.regenerateAlertPresented = true }
        ) {
            Image(systemName: "arrow.clockwise")
                .contentShape(Rectangle())
                .padding(.horizontal, 8)
                .imageScale(.medium)
        }.disabled(!vm.executionAvailable)
    }

    private var summarizeButton: some View {
        if vm.bussy {
            Button(
                action: { vm.cancelSummarize() }
            ) {
                Image(systemName: "stop.fill")
                    .contentShape(Rectangle())
                    .padding(.horizontal, 8)
            }
            .disabled(!vm.executionAvailable)
        } else {
            Button(
                action: {
                    vm.showOriginals = false
                    vm.sumarizeAll()
                }
            ) {
                Image(systemName: "play.fill")
                    .contentShape(Rectangle())
                    .padding(.horizontal, 8)
            }
            .disabled(!vm.executionAvailable)
        }
    }
}

#Preview {
    @Previewable @State var mocks: [ChatData] = [
        MockChatData(),
        MockChatData(),
        MockChatData(),
        MockChatData(),
        MockChatData(),
    ]
    NewsConversationView(chats: $mocks)
        .frame(width: 1000, height: 500)
}
