//
//  NewsActionView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 14.04.2025.
//

import SwiftUI

struct NewsActionView: View {
    @State var newsItems: [any NewsBehavior]
    
    @State var selectedMode: Int = 1
    
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
                List(newsItems, id: \.title) { item in
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
                }
            }.background(.background)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 24, height: 24)))
                .padding(8)
            VStack(alignment: .trailing) {
                HStack {
                    Image(systemName: "arrow.forward")
                        .imageScale(.large)
                        .fontWeight(.bold)
                        .padding(8)
                    VStack {
                        HStack {
                            Picker(
                                selection: $selectedMode,
                                content: {
                                    Text("Better Quality (T5 Small)").tag(1)
                                    Text("Better Performance (T5)").tag(2)
                                    Text("Prompt").tag(3)
                                },
                                label: {
                                    Text("Model")
                                }
                            ).frame(minWidth: 256)
                        }.padding(16)
                            .background(.background)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 24, height: 24)))
                    }
                }.padding(.top, 8)
                    .padding(.trailing, 8)
                ScrollView {
                    VStack {
                        ForEach(newsItems, id: \.title) { item in
                            Text("\(item.full ?? "")")
                                .padding(4)
                        }
                    }
                }.padding(8)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 24, height: 24)))
                    .padding([.bottom, .trailing], 8)
                Spacer()
            }
        }
    }
}

#Preview {
    // AXAXAXAXA
    @Previewable @State var mocks: [SecurityLabNews] = [SecurityLabNews(
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
    NewsActionView(newsItems: mocks)
        .frame(width: 1000, height: 500)
}
