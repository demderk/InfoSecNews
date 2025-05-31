//
//  NewsCard.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 23.02.2025.
//

import SwiftUI

struct NewsCard: View, Equatable {
    static func == (lhs: NewsCard, rhs: NewsCard) -> Bool {
        lhs.newsItem.title == rhs.newsItem.title
    }

    @State var newsItem: any NewsBehavior

    @State private var text: String
    @State private var hasFull: Bool = false
    @State private var buttonAngle: Double = 0
    @State private var opened: Bool = false
    @State private var textHeight: CGFloat = 0
    @State private var isLoading: Bool = false
    @State private var failed: Bool = false

    @State private var copyLinkImageName: String = "link"
    @State private var copyTextImageName: String = "document.on.document"
    @State private var appendImageName: String = "document.on.document"

    @Binding var isSelected: Bool

    let voyager: WebVoyager

    init(newsItem: any NewsBehavior, voyager: WebVoyager, isSelected: Binding<Bool>) {
        self.newsItem = newsItem
        hasFull = true
        text = newsItem.short
        self.voyager = voyager
        _isSelected = isSelected
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                newsInfo
                Text(newsItem.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
                    .layoutPriority(1)
                newsBody(opened ? text : newsItem.short)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(
                minWidth: 256,
                maxWidth: 896,
                maxHeight: .infinity,
                alignment: .leading
            )

            Spacer()
            VStack(alignment: .trailing) {
                toolBox
                if opened {
                    Spacer()
                }
                if hasFull {
                    expansionButton
                }
            }
            .padding(32)
        }
        .background(.background)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray.opacity(0.1), lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    var newsInfo: some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .fontWeight(.semibold)
                Text(newsItem.date.formatted(date: .complete, time: .omitted))
            }
            HStack(spacing: 4) {
                Image(systemName: "newspaper")
                    .fontWeight(.semibold)
                Text(newsItem.source)
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 4)
    }

    func newsBody(_ text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .font(.title3)
            .frame(maxHeight: .infinity)
            .textSelection(.enabled)
            .transition(.opacity)
            .layoutPriority(0)
    }

    var expansionButton: some View {
        Button(action: openFullText) {
            ZStack {
                Image(systemName: failed ? "xmark" : "chevron.down")
                    .font(.system(size: 20, weight: .medium))
                    .opacity(isLoading ? 0 : 1)
                ProgressView().progressViewStyle(.circular)
                    .opacity(isLoading ? 0.9 : 0)
                    .scaleEffect(0.5)
            }.foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.gray.opacity(0.03))
                .rotationEffect(.degrees(buttonAngle))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.leading, 96)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func buildToolButton(
        action: @escaping () -> Void,
        systemImageName: String
    )
        -> some View
    {
        Button(action: action) {
            if #available(macOS 15.0, *) {
                Image(systemName: systemImageName)
                    .imageScale(.medium)
                    .fontWeight(.bold)
                    .frame(width: 11, height: 11)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.gray.opacity(0.03))
                    .contentTransition(
                        .symbolEffect(
                            .replace.magic(fallback: .downUp.byLayer),
                            options: .nonRepeating
                        ))
            } else {
                Image(systemName: systemImageName)
                    .imageScale(.medium)
                    .fontWeight(.bold)
                    .frame(width: 11, height: 11)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.gray.opacity(0.03))
            }
        }.buttonStyle(.plain)
    }

    var toolBox: some View {
        HStack {
            if opened {
                HStack(alignment: .center, spacing: 0) {
                    buildToolButton(
                        action: copyLink,
                        systemImageName: copyLinkImageName
                    )
                    Divider()
                        .frame(height: 16)
                    buildToolButton(
                        action: copyText,
                        systemImageName: copyTextImageName
                    )
                    Divider()
                        .frame(height: 16)
                    buildToolButton(
                        action: onAppend,
                        systemImageName: isSelected ? "checkmark.square" : "minus.square"
                    )
                }
                .background(.gray.opacity(0.03))
                .foregroundStyle(.secondary)
                .clipShape(Capsule())
                Button(action: openFullText) {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .fontWeight(.bold)
                        .frame(width: 11, height: 11)
                        .padding(4)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(.gray.opacity(0.03))
                        .foregroundStyle(.secondary)
                        .clipShape(Capsule())
                }.buttonStyle(.plain)
            }
        }
        .opacity(opened ? 1 : 0)
    }

    private func openFullText() {
        if !opened {
            if let full = newsItem.full {
                text = full
                withAnimation {
                    buttonAngle = 180
                    opened = true
                }
                return
            }
            isLoading = true
            Task {
                do {
                    try await newsItem.loadRemoteData(voyager: voyager)
                    let text = newsItem.full ?? "nope"
                    DispatchQueue.main.async {
                        self.text = text
                        withAnimation {
                            isLoading = false
                            buttonAngle = 180
                            opened = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        withAnimation {
                            isLoading = false
                            opened = false
                            failed = true
                        }
                        Task {
                            try? await Task.sleep(for: .seconds(3))
                            DispatchQueue.main.async {
                                withAnimation {
                                    failed = false
                                }
                            }
                        }
                    }
                }
            }
        } else {
            withAnimation {
                buttonAngle = 0
                opened = false
            }
        }
    }

    private func copyLink() {
        withAnimation {
            copyLinkImageName = "checkmark"
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(newsItem.fullTextLink.absoluteString, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            withAnimation {
                copyLinkImageName = "link"
            }
        }
    }

    private func copyText() {
        if let full = newsItem.full {
            withAnimation {
                copyTextImageName = "checkmark"
            }
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(full, forType: .string)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                withAnimation {
                    copyTextImageName = "document.on.document"
                }
            }
        }
    }

    func onAppend() {
        isSelected = !isSelected
    }
}

#Preview {
    VStack {
        NewsCard(
            newsItem: MockNewsItem(),
            voyager: WebVoyager(),
            isSelected: Binding.constant(false)
        )
        NewsCard(
            newsItem: MockNewsItem(),
            voyager: WebVoyager(),
            isSelected: Binding.constant(false)
        )
        NewsCard(
            newsItem: MockNewsItem(),
            voyager: WebVoyager(),
            isSelected: Binding.constant(false)
        )
        NewsCard(
            newsItem: MockNewsItem(),
            voyager: WebVoyager(),
            isSelected: Binding.constant(false)
        )
    }
    .frame(width: 1024)
    .background(.background)
}
