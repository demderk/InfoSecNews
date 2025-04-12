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
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(parentViewModel.storage, id: \.id) { item in
                            EquatableView(content:
                                            NewsCard(newsItem: item, voyager: parentViewModel.voyager))
                            .listRowSeparator(.hidden)
                            .id(item.id)
                        }
                    }
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .onAppear(perform: parentViewModel.fetchContent)
                            .opacity(0.9)
                            .scaleEffect(0.5)
                        Spacer()
                    }
                }.onChange(of: parentViewModel.enabledModules) {
                    if let id = parentViewModel.storage.first?.id {
                        withAnimation {
                            proxy.scrollTo(id)
                        }
                    }
                }
            }
        }.navigationTitle("InfoSecNews → Feed")
            .toolbar {
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(parentViewModel.bussy ? 1 : 0)
                    .scaleEffect(0.5)
                Button(action: {
                    modulesPopoverPresented.toggle()
                }, label: {
                    Image(systemName: "newspaper")
                }).popover(isPresented: $modulesPopoverPresented) {
                    VStack(alignment: .leading) {
                        Text("Enabled Modules")
                            .font(.body)
                            .fontWeight(.semibold)
                            .padding(.trailing, 32)
                        Divider()
                        ForEach(EnabledModules.allCases) { module in
                            Toggle(isOn: bindCheckbox(module: module), label: { Text(module.UIName) })
                        }
                    }.padding(16)
                }
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
            })
    }
}
