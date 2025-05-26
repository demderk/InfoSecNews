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
            List(selection: $feedVM.currentWindow) {
                Section(header: Text("Tools")) {
                    HStack {
                        Image(systemName: SelectedWindow.home.imageString)
                            .frame(width: 24)
                            .fontWeight(.black)
                        Spacer().frame(width: 2)
                        Text(SelectedWindow.home.title)
                    }.tag(SelectedWindow.home)
                    HStack {
                        Image(systemName: SelectedWindow.conversations.imageString)
                            .frame(width: 24)
                            .fontWeight(.semibold)
                        Spacer().frame(width: 2)
                        Text(SelectedWindow.conversations.title)
                    }.tag(SelectedWindow.conversations)
                }
                if !feedVM.enabledModules.isEmpty {
                    Section(header: Text("News Sources")) {
                        ForEach(
                            SelectedWindow.allCases[1..<SelectedWindow.allCases.count-1],
                            id: \.self
                        ) { item in
                            if let enabled = item.asEnabledModule, feedVM.enabledModules.contains(enabled) {
                                HStack {
                                    Image(systemName: item.imageString)
                                        .frame(width: 24)
                                        .fontWeight(.semibold)
                                    Spacer().frame(width: 2)
                                    Text(item.title)
                                }
                            }
                        }
                    }
                }
                if !feedVM.enabledModules.isEmpty {
                    Section(header: Text("Misc")) {
                        NavigationLink(value: SelectedWindow.voyager) {
                            HStack {
                                Image(systemName: SelectedWindow.voyager.imageString)
                                    .frame(width: 24)
                                    .fontWeight(.semibold)
                                Spacer().frame(width: 2)
                                Text(SelectedWindow.voyager.title)
                            }.tag(SelectedWindow.voyager)
                        }
                    }
                }
            }
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
}

#Preview {
    ContentView()
}
