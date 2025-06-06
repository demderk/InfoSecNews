//
//  SettingsView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 04.06.2025.
//

import SwiftUI

struct SettingsView: View {
    @State var vm: SettingsVM = .init()

    @FocusState var urlFocused: Bool
    @FocusState var messageFocused: Bool

    var body: some View {
        TabView {
            ollamaSettings
                .tabItem {
                    Label("Ollama", systemImage: "quote.bubble")
                }
        }
        .padding(.vertical, 32)
    }

    var generalSettings: some View {
        Text("General")
    }

    var ollamaSettings: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Remote Address:")
                    .frame(width: 160, alignment: .trailing)
                VStack(alignment: .trailing) {
                    TextField("http://127.0.0.1:11434", text: $vm.url)
                        .frame(width: 384)
                        .modifier(Shake(animatableData: CGFloat(vm.wrongAttempts)))
                        .focused($urlFocused)
                        .onSubmit {
                            vm.tryConnect()
                        }
                        .onChange(of: vm.url) {
                            vm.remoteUpdated.send()
                        }
                        .onChange(of: urlFocused) {
                            vm.remoteUpdated.send()
                        }
                    Text(vm.status)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Text("Model system message:")
                    .frame(width: 160, alignment: .trailing)
                TextEditor(text: $vm.systemMessage)
                    .frame(width: 384, height: 128)
                    .padding(.vertical, 4)
                    .background(.background)
                    .focused($messageFocused)
                    .onChange(of: vm.systemMessage) {
                        vm.messageUpdated.send()
                    }
                    .onChange(of: messageFocused) {
                        vm.messageUpdated.send()
                    }
            }
            .padding(.horizontal, 16)
            HStack {
                Text("Default Settings:")
                    .frame(width: 160, alignment: .trailing)
                Button(
                    action: {
                        vm.useDefaultSettings()
                    },
                    label: {
                        Text("Use Default Settings")
                            .padding(.horizontal, 16)
                    }
                )
                .frame(width: 384, alignment: .leading)

            }
        }
    }
}

#Preview {
    SettingsView()
}
