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
    case securityMedia
    case securityLab
    
    var title: String {
        switch self {
        case .home:
            "Feed"
        case .securityMedia:
            "SecurityMedia"
        case .securityLab:
            "SecurityLab"
        }
    }
    
    var imageString: String {
        switch self {
        case .home:
            "dot.radiowaves.up.forward"
        case .securityMedia:
            "network"
        case .securityLab:
            "network"
        }
    }
}


struct ContentView: View {
    @State var vm = MainVM()
        
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $vm.currentWindow) {
                Section(header: Text("Control")) {
                    NavigationLink(value: SelectedWindow.home) {
                        HStack {
                            Image(systemName: SelectedWindow.home.imageString)
                                .frame(width: 24)
                                .fontWeight(.black)
                            Spacer().frame(width: 2)
                            Text(SelectedWindow.home.title)
                        }.tag(SelectedWindow.home)
                    }
                }
                Section(header: Text("News Modules")) {
                    ForEach(SelectedWindow.allCases[1...], id: \.self) { item in
                        NavigationLink(value: item) {
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
        }, detail: {
            VStack {
                switch vm.currentWindow {
                case .securityMedia:
                    WebView(vm.secmed.webKit)
                case .securityLab:
                    WebView(vm.seclab.webKit)
                case .home:
                    VStack {
                        Spacer().frame(height: 8)
                        List(vm.storage, id: \.self) { item in
                            NewsCard(newsItem: item)
                                .listRowSeparator(.hidden)
                        }.listStyle(.plain)
                        Spacer().frame(height: 8)
                        
                    }
                }
                
            }.background(.background)
        })
    }
}

#Preview {
    ContentView()
}
