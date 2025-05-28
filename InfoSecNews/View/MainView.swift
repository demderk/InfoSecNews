//
//  ContentView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI

enum SelectedWindow: CaseIterable, Identifiable {
    var id: Self { self }
    
    case home
    case conversations
    case securityMedia
    case securityLab
    case antiMalware
    case voyager
    
    var title: String {
        switch self {
        case .home:
            "Feed"
        case .securityMedia:
            "SecurityMedia"
        case .securityLab:
            "SecurityLab"
        case .antiMalware:
            "Anti-Malware"
        case .voyager:
            "Web Voyager"
        case .conversations:
            "Conversations"
        }
    }
    
    var imageString: String {
        switch self {
        case .home:
            "dot.radiowaves.up.forward"
        case .securityMedia, .antiMalware, .securityLab:
            "network"
        case .voyager:
            "location.square"
        case .conversations:
            "bubble.left.and.bubble.right"
        }
    }
    
    var asEnabledModule: EnabledModules? {
        switch self {
        case .securityMedia:
            EnabledModules.securityMedia
        case .securityLab:
            EnabledModules.securityLab
        case .antiMalware:
            EnabledModules.antiMalware
        default: nil
        }
    }
}

struct ContentView: View {
    @State var feedVM = FeedVM()
        
    var body: some View {
        NavigationSplitView(sidebar: {
            sidebar
        }, detail: {
            VStack {
                switch feedVM.currentWindow {
                case .securityMedia:
                    WebView(feedVM.secmed.webKit)
                        .navigationTitle("InfoSecNews → Sources → Security Media")
                case .securityLab:
                    WebView(feedVM.seclab.webKit)
                        .navigationTitle("InfoSecNews → Sources → Security Lab")
                case .antiMalware:
                    WebView(feedVM.antMal.webKit)
                        .navigationTitle("InfoSecNews → Sources → Anti-Malware")
                case .home:
                    FeedView()
                        .environment(feedVM)
                case .voyager:
                    if feedVM.voyager.htmlBody != nil {
                        WebView(feedVM.voyager.webKit)
                            .navigationTitle("InfoSecNews → Web Voyager")
                    } else {
                        VStack {
                            Spacer()
                            Text("Web Voyager is still in the launchpad")
                                .font(.title)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }.navigationTitle("InfoSecNews → Web Voyager")
                    }
                case .conversations:
                    NewsConversationView(chats: $feedVM.chats)
                }
                
            }
        })
    }
    
    func makeSidebarItem(title: String, imageSystemName: String, imageSize: CGFloat = 15) -> some View {
        HStack(spacing: 8) {
            Image(systemName: imageSystemName)
                .font(.system(size: imageSize))
                .frame(width: 15, alignment: .leading)
                .fontWeight(.medium)
                .padding(.horizontal, 2)
            Text(title)
        }
    }
    
    // TODO: Вот это такое говно... Надо переписать
    
    var sidebar: some View {
        List(selection: $feedVM.currentWindow) {
            Section(header: Text("Tools")) {
                makeSidebarItem(
                    title: SelectedWindow.home.title,
                    imageSystemName: SelectedWindow.home.imageString
                )
                .tag(SelectedWindow.home)
                
                makeSidebarItem(title: SelectedWindow.conversations.title,
                                imageSystemName: SelectedWindow.conversations.imageString,
                                imageSize: 11
                )
                .tag(SelectedWindow.conversations)
            }
            if !feedVM.enabledModules.isEmpty {
                Section(header: Text("News Sources")) {
                    ForEach(
                        SelectedWindow.allCases[1..<SelectedWindow.allCases.count-1],
                        id: \.self
                    ) { item in
                        if let enabled = item.asEnabledModule, feedVM.enabledModules.contains(enabled) {
                            makeSidebarItem(title: item.title, imageSystemName: item.imageString)
                        }
                    }
                }
            }
            if !feedVM.enabledModules.isEmpty {
                Section(header: Text("Misc")) {
                    makeSidebarItem(title: SelectedWindow.voyager.title, imageSystemName: SelectedWindow.voyager.imageString)
                        .tag(SelectedWindow.voyager)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
