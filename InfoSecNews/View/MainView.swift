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
    @State var htmlContent = "Wait..."
    
    @State var currentWindow: SelectedWindow = .home
    
    @Environment(\.openWindow) var openWindow
    
    var secmod = SecurityMediaNewsModule()
    @ObservedObject var secmodVM: WebViewVM
    
    var newsModules: [SelectedWindow:any NewsModule] = [:]
    
    init() {
        newsModules = [
            .securityMedia:secmod
        ]
        secmodVM = secmod.webVM
    }
    
    var body: some View {
        print("New body")
        return NavigationSplitView(sidebar: {
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
                Text(secmodVM.htmlContent)
//                Button("1") {
//                    print(try! (newsModules[.securityMedia] as! SecurityMediaNewsModule).parse())
//                }
                if let view = newsModules[currentWindow] {
                    view.webWindow
                } else {
                    Text("No view")
                }
            }
        })
    }
}

#Preview {
    ContentView()
}
