//
//  NewsActionView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 14.04.2025.
//

import SwiftUI

struct NewsActionView: View {
    @Binding var newsItems: [any NewsBehavior]
    
    @State var vm: NewsActionVM = NewsActionVM()
 
    var body: some View {
        HSplitView {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("News Collection")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(newsItems.count) Items")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                Spacer().frame(height: 8)
                Divider()
                Spacer().frame(height: 0)
                List {
                    ForEach(newsItems, id: \.title) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .padding(.bottom, 4)
                                .padding(.leading, 4)
                            Text(item.short)
                                .lineLimit(3)
                                .lineSpacing(1.3)
                                .padding(.leading, 4)
                                .padding(.bottom, 8)
                        }
                    }.onDelete { i in
                        newsItems.remove(atOffsets: i)
                    }
                }
            }.background(.background)
                .frame(minWidth: 256, idealWidth: 256)
                .layoutPriority(0)
            VStack(alignment: .leading) {
                HStack {
                    Text("News Export")
                        .font(.title2)
                        .fontWeight(.medium)
                    Button("Push", action: {vm.ollamaPush(newsItems: newsItems)})
                    Spacer()
                    Picker(
                        selection: $vm.selectedModeName,
                        content: {
                            Text("Prompt").tag("prompt")
                            ForEach(vm.availableModels, id: \.name) { available in
                                Text(available.name)
                            }
                        },
                        label: {
                            Text("Model")
                        }
                    ).frame(maxWidth: 256)
                }.padding(.vertical, 10).padding(.horizontal, 16)
                Spacer().frame(height: 0)
                Divider()
                Spacer().frame(height: 0)
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack { Spacer() }
                        ForEach(vm.chats) { item in
                            ChatCardView(conversation: item)
                        }
//                        ForEach(vm.neuroNewsCollection) { item in
//                            Text("\(item.summary)")
//                                .padding(2)
//                                .textSelection(.enabled)
////                            Text("\(stream.text ?? "")")
////                                .padding(2)
////                                .textSelection(.enabled)
//                        }
                    }
                }.padding(.horizontal, 8)
            }.background(.background)
                .layoutPriority(1)
        }
    }
}

#Preview {
    // AXAXAXAXA
    @Previewable @State var mocks: [any NewsBehavior] = [SecurityLabNews(
        source: "debug.fm",
        title: "Белый дом запретит судам принимать иски против Белого дома",
        date: .now,
        short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
        full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."), SecurityLabNews(
            source: "debug.fm",
            title: "Белый дом запретит судам принимать иски против Белого дома",
            date: .now,
            short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
            full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."), SecurityLabNews(
                source: "debug.fm",
                title: "Белый дом запретит судам принимать иски против Белого дома",
                date: .now,
                short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
                full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права."), SecurityLabNews(
                    source: "debug.fm",
                    title: "Белый дом запретит судам принимать иски против Белого дома",
                    date: .now,
                    short: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.", fullTextLink: URL(string: "google.com")!,
                    full: "Пресс-секретарь Белого дома Робин Маусс объявил, что президент готовится запретить судам принимать иски против него самого и Белого дома в целом. Он также объяснил, почему готовящийся указ никак не противоречит верховенству права.")]
    NewsActionView(newsItems: $mocks)
        .frame(width: 1000, height: 500)
}
