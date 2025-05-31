//
//  HomeView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.03.2025.
//

import SwiftUI

struct FeedView: View {
    @Environment(MainVM.self) var parentViewModel
    
    @State var modulesPopoverPresented: Bool = false
    @State var startSelectedModules: EnabledModules = []
    
    var body: some View {
        VStack {
            if !parentViewModel.enabledModules.isEmpty {
                feed
            } else {
                startPage
            }
        }
        .toolbar {
            ProgressView()
                .progressViewStyle(.circular)
                .opacity(parentViewModel.bussy ? 1 : 0)
                .scaleEffect(0.5)
            
            if !parentViewModel.enabledModules.isEmpty {
                Button(action: {
                    modulesPopoverPresented.toggle()
                }, label: {
                    Image(systemName: "newspaper")
                })
                .popover(isPresented: $modulesPopoverPresented) {
                    newsPickerPopover
                }
            }
        }
    }
    
    var feed: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(parentViewModel.storage, id: \.id) { item in
                        EquatableView(content:
                            NewsCard(newsItem: item,
                                     voyager: parentViewModel.voyager,
                                     isSelected: bindNewsIsSelected(newsItem: item)
                            )
                        )
                        .listRowSeparator(.hidden)
                        .id(item.id)
                    }
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .onAppear(perform: parentViewModel.spinnerAppear)
                            .opacity(0.9)
                            .scaleEffect(0.5)
                        Spacer()
                    }
                }
                .padding(.vertical, 16)
            }.onChange(of: parentViewModel.enabledModules) {
                if let id = parentViewModel.storage.first?.id {
                    withAnimation {
                        proxy.scrollTo(id)
                    }
                }
            }
        }
        .background(.background)
    }
    
    var newsPickerPopover: some View {
        VStack(alignment: .leading) {
            Text("Enabled Sources")
                .font(.body)
                .fontWeight(.semibold)
                .padding(.trailing, 32)
            Divider()
            ForEach(EnabledModules.allCases) { module in
                Toggle(isOn: bindCheckbox(module: module), label: { Text(module.UIName) })
            }
        }
        .padding(16)
    }
    
    var startNewsPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(EnabledModules.allCases.enumerated()), id: \.offset) { (i, module) in
                Toggle(isOn: bindStarterCheckbox(module: module), label: {
                    Text(module.UIName)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                if i != (EnabledModules.allCases.count - 1) {
                    Divider()
                }
            }
        }
        .padding(.leading, 32)
        .padding(.vertical, 16)
        .background(.background.opacity(0.4))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 24, height: 24)))
        .frame(maxWidth: 512)
    }
    
    var startPage: some View {
        VStack(spacing: 0) {
            VStack {
                Text("No news sources selected")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 64)
                Text("Pick a news source to get started")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            startNewsPicker
                .padding(.top, 32)
            HStack {
                Spacer()
                Button(action: onContinue) {
                    Text("Start Reading")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(startSelectedModules.isEmpty)
            }
            .frame(maxWidth: 512)
            .padding(.bottom, 16)
            .padding(.top, 16)
        }
    }
    
    private func bindCheckbox(module: EnabledModules) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                parentViewModel.enabledModules.contains(module)
            },
            set: { isOn in
                if isOn {
                    parentViewModel.enabledModules.insert(module)
                    parentViewModel.syncModules()
                } else {
                    parentViewModel.enabledModules.remove(module)
                }
                parentViewModel.saveSelectedModules()
            })
    }
    
    private func bindStarterCheckbox(module: EnabledModules) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                startSelectedModules.contains(module)
            },
            set: { isOn in
                if isOn {
                    startSelectedModules.insert(module)
                } else {
                    startSelectedModules.remove(module)
                }
            })
    }
    
    private func bindNewsIsSelected(newsItem: any NewsBehavior) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                parentViewModel.hasChat(news: newsItem)
            }, set: { new in
                if new {
                    parentViewModel.createChat(news: newsItem)
                } else {
                    parentViewModel.removeChat(news: newsItem)
                }
            }
        )
    }
    
    private func onContinue() {
        parentViewModel.enabledModules = startSelectedModules
        parentViewModel.saveSelectedModules()
        startSelectedModules = []
    }
}

#Preview {
    @Previewable @State var vm = MainVM()
    
    FeedView()
        .environment(vm)
}
