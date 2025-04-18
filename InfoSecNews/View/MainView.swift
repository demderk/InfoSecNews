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
    case export
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
        case .export:
            "Export to AI"
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
        case .export:
            "tray.and.arrow.up"
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
    @State var vm = MainVM()
        
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $vm.currentWindow) {
                Section(header: Text("Tools")) {
                    HStack {
                        Image(systemName: SelectedWindow.home.imageString)
                            .frame(width: 24)
                            .fontWeight(.black)
                        Spacer().frame(width: 2)
                        Text(SelectedWindow.home.title)
                    }.tag(SelectedWindow.home)
                    HStack {
                        Image(systemName: SelectedWindow.export.imageString)
                            .frame(width: 24)
                            .fontWeight(.semibold)
                        Spacer().frame(width: 2)
                        Text(SelectedWindow.export.title)
                    }.tag(SelectedWindow.export)
                }
                if !vm.enabledModules.isEmpty {
                    Section(header: Text("News Sources")) {
                        ForEach(
                            SelectedWindow.allCases[1..<SelectedWindow.allCases.count-1],
                            id: \.self
                        ) { item in
                            if let enabled = item.asEnabledModule, vm.enabledModules.contains(enabled) {
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
                if !vm.enabledModules.isEmpty {
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
                switch vm.currentWindow {
                case .securityMedia:
                    WebView(vm.secmed.webKit)
                        .navigationTitle("InfoSecNews → Sources → Security Media")
                case .securityLab:
                    WebView(vm.seclab.webKit)
                        .navigationTitle("InfoSecNews → Sources → Security Lab")
                case .antiMalware:
                    WebView(vm.antMal.webKit)
                        .navigationTitle("InfoSecNews → Sources → Anti-Malware")
                case .home:
                    FeedView()
                        .environment(vm)
                case .voyager:
                    if vm.voyager.htmlBody != nil {
                        WebView(vm.voyager.webKit)
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
                case .export:
                    NewsActionView(newsItems: $vm.selectedNews)
                }
                
            }
        })
    }
}

#Preview {
    ContentView()
}
