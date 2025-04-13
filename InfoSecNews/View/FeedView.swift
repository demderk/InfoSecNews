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
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(parentViewModel.storage, id: \.id) { item in
                                EquatableView(content:
                                                NewsCard(newsItem: item, voyager: parentViewModel.voyager))
                                .listRowSeparator(.hidden)
                                .id(item.id)
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
                        }
                    }.onChange(of: parentViewModel.enabledModules) {
                        if let id = parentViewModel.storage.first?.id {
                            withAnimation {
                                proxy.scrollTo(id)
                            }
                        }
                    }
                }.background(.background)
            } else {
                HStack {
                    Spacer()
                }
                Spacer()
                Text("No news sources selected")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding(.top, 64)
                Spacer().frame(height: 8)
                Text("You can select a news source in the menu below")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer().frame(height: 32)
                VStack(alignment: .leading) {
                    ForEach(Array(EnabledModules.allCases.enumerated()), id: \.offset) { (i, module) in
                        Toggle(isOn: bindStarterCheckbox(module: module), label: {
                            Text(module.UIName)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        })
                        Spacer().frame(height: 0)
                        if i != (EnabledModules.allCases.count - 1) {
                            Divider()
                        }
                        Spacer().frame(height: 0)
                    }
                }
                .padding(.leading, 32)
                .padding(.vertical, 8)
                .background(.background.opacity(0.4))
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 24, height: 24)))
                .frame(maxWidth: 512)
                HStack {
                    Spacer()
                    Button(action: onContinue) {
                        Text("Continue")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }.buttonStyle(.plain)
                        .disabled(startSelectedModules.isEmpty)
                }.frame(maxWidth: 512)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                
                Spacer()
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
