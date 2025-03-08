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
    case voyager
    //    case securityLab
    
    var title: String {
        switch self {
        case .home:
            "Feed"
        case .securityMedia:
            "SecurityMedia"
        case .voyager:
            "Web Voyager"
        }
    }
    
    var imageString: String {
        switch self {
        case .home:
            "dot.radiowaves.up.forward"
        case .securityMedia:
            "network"
        case .voyager:
            "location.square"
        }
    }
}

struct ContentView: View {
    @State var vm = MainVM()
        
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $vm.currentWindow) {
                Section(header: Text("Tools")) {
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
                    ForEach(SelectedWindow.allCases[1..<SelectedWindow.allCases.count-1], id: \.self) { item in
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
        }, detail: {
            VStack {
                switch vm.currentWindow {
                case .securityMedia:
                    WebView(vm.secmed.webKit)
                case .home:
                    FeedView()
                        .environment(vm)
                case .voyager:
                    WebView(vm.voyager.webKit)
                }
                
            }.background(.background)
        })
    }
}

#Preview {
    ContentView()
}
