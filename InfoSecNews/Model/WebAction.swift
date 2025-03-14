//
//  WebAction.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 15.03.2025.
//

import WebKit

class WebAction: Identifiable, Equatable{
    typealias Action = (_ html: String?, _ webView: WKWebView) -> Void
    
    var id = UUID()
    var action: Action
    
    init(_ action: @escaping Action) {
        self.action = action
    }
    
    static func == (lhs: WebAction, rhs: WebAction) -> Bool {
        lhs.id == lhs.id
    }
}