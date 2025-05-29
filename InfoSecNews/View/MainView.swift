//
//  MainView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI

struct MainView: View {
    @State var vm = MainVM()
        
    var body: some View {
        NavigationSplitView(sidebar: {
            sidebar
        }, detail: {
            drawDetails()
                .navigationTitle("InfoSecNews → \(vm.currentWindow.title)")
        })
    }
    
    @ViewBuilder
    func drawDetails() -> some View {
        switch vm.currentWindow {
        case .securityMedia:
            WebView(vm.secmed.webKit)
        case .securityLab:
            WebView(vm.seclab.webKit)
        case .antiMalware:
            WebView(vm.antMal.webKit)
        case .home:
            FeedView()
                .environment(vm)
        case .conversations:
            NewsConversationView(chats: $vm.chats)
        case .voyager:
            if vm.hasVoyager {
                WebView(vm.voyager.webKit)
            } else {
                voyagerMissingView()
            }
        }
    }
    
    func voyagerMissingView() -> some View {
        VStack {
            Spacer()
            Text("Web Voyager is still in the launchpad")
                .font(.title)
                .foregroundStyle(.secondary)
            Spacer()
        }
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
        
    func moduleIsPresented(window: MainViewSelectedDetail) -> Bool {
        switch window {
        case .securityLab, .securityMedia, .antiMalware:
            if let module = window.asEnabledModule,
               vm.enabledModules.contains(module) {
                return true
            } else { return false }
        default: return true
        }
    }
    
    var sidebar: some View {
        List(selection: $vm.currentWindow) {
            ForEach(MainViewSelectedDetail.groups, id: \.name) { item in
                Section(header: Text(item.name)) {
                    ForEach(item.items) { view in
                        if moduleIsPresented(window: view) {
                            makeSidebarItem(
                                title: view.title,
                                imageSystemName: view.imageString,
                                imageSize: view.iconSize
                            )
                            .tag(view)
                        }
                    }
                }
            }
        }
        
//        List(selection: $feedVM.currentWindow) {
//            Section(header: Text("Tools")) {
//                makeSidebarItem(
//                    title: SelectedWindow.home.title,
//                    imageSystemName: SelectedWindow.home.imageString
//                )
//                .tag(SelectedWindow.home)
//                
//                makeSidebarItem(title: SelectedWindow.conversations.title,
//                                imageSystemName: SelectedWindow.conversations.imageString,
//                                imageSize: 11
//                )
//                .tag(SelectedWindow.conversations)
//            }
//            if !feedVM.enabledModules.isEmpty {
//                Section(header: Text("News Sources")) {
//                    ForEach(
//                        SelectedWindow.allCases[1..<SelectedWindow.allCases.count-1],
//                        id: \.self
//                    ) { item in
//                        if let enabled = item.asEnabledModule, feedVM.enabledModules.contains(enabled) {
//                            makeSidebarItem(title: item.title, imageSystemName: item.imageString)
//                        }
//                    }
//                }
//            }
//            if !feedVM.enabledModules.isEmpty {
//                Section(header: Text("Misc")) {
//                    makeSidebarItem(title: SelectedWindow.voyager.title, imageSystemName: SelectedWindow.voyager.imageString)
//                        .tag(SelectedWindow.voyager)
//                }
//            }
//        }
    }
}

#Preview {
    MainView()
}
