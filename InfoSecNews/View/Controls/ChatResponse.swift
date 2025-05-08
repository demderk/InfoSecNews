//
//  ChatResponse.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 08.05.2025.
//

import SwiftUI

struct ChatResponse: View {    
    @Binding var title: String
    @Binding var content: String
    
    @State var background: Color = .gray.opacity(0.1)
    @State var foreground: Color = .primary
    @State var buttonsBackground: Color = .white.opacity(0.3)
    
    var onRefresh: (() -> Void)?
    var onChatOpen: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer().frame(height: 4)
                Text(content)
                HStack {
                    Button(action: {}) {
                        Image(systemName: "document.on.document")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(buttonsBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .foregroundStyle(foreground.opacity(0.8))
                    }.buttonStyle(.plain)
                    Spacer().frame(width: 4)
                    if let refreshAction = onRefresh {
                        Button(action: refreshAction) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(buttonsBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .foregroundStyle(foreground.opacity(0.8))
                        }.buttonStyle(.plain)
                        Spacer().frame(width: 4)
                    }
                    
                    if let chatAction = onChatOpen {
                        Button(action: chatAction) {
                            Image(systemName: "bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(buttonsBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .foregroundStyle(foreground.opacity(0.8))
                        }.buttonStyle(.plain)
                    }
                    Spacer()
                }
            }
            .padding(16)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
        }
    }
}

extension ChatResponse {
    func onChatOpen(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onChatOpen = action
        return copy
    }
    
    func onRefresh(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onRefresh = action
        return copy
    }
}

#Preview {
//    ChatResponse(title: .constant("Title"), content: .constant("Some"), background: .blue, foreground: .white, buttonsBackground: .white.opacity(0.15))
}
