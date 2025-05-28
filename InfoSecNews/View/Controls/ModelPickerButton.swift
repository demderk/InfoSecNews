//
//  ModelPickerButton.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 27.05.2025.
//

import Foundation
import SwiftUI

struct ModelPickerButton<Label: View>: View {
    @State private var isHovered: Bool = false
    @Binding var isSelected: Bool
    
    var content: () -> Label
    var action: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .imageScale(.small)
                .opacity(isSelected ? 1 : 0)
            content()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(isHovered ? Color.white : Color.primary)
        .background(isHovered ? Color.accentColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onHover(perform: {
            isHovered = $0
        })
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    ModelPickerButton(isSelected: .constant(true)) {
        Text("Hello, World!")
    } action: {  }
}
