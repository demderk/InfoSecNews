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
    
    var title: String {
        switch self {
        case .home:
            "Home"
        case .securityMedia:
            "securitymedia.com"
        }
    }
    
    var imageString: String {
        switch self {
        case .home:
            "house"
        case .securityMedia:
            "globe"
        }
    }
}


struct ContentView: View {
    @StateObject var vm = MainVM()
    
    @State var currentWindow: SelectedWindow = .home
    
    @StateObject var secmod = SecurityMediaNewsModule()
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $currentWindow) {
                Section(header: Text("Control")) {
                    NavigationLink(value: SelectedWindow.home) {
                        HStack {
                            Image(systemName: SelectedWindow.home.imageString)
                                .frame(width: 24)
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
                                Text(item.title)
                            }
                        }
                    }
                }
            }
        }, detail: {
            VStack {
                ScrollView {
                    ForEach(secmod.newsCollection, id: \.self) { item in
                        Text(item.title)
                    }
                }
                Button("1") {
                    print(try! secmod.fetch())
                }
                switch currentWindow {
                case .securityMedia:
                    WebView<SecurityMediaNewsModule>(secmod)
                default:
                    Text("No view")
                }
            }
        })
    }
}

#Preview {
    ContentView()
}
