//
//  WebView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI
import WebKit
import AppKit

struct WebView: NSViewRepresentable {
    private var webKitHead: WebKitHead!
    
    func makeNSView(context: Context) -> WKWebView {
        return webKitHead.webView
    }
    
    init(_ module: WebKitHead) {
        webKitHead = module
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }

    func makeCoordinator() -> WKWebViewNavigationCoordinator {
        webKitHead.coordinator
    }
}

class WebKitStaticHostCoordinator: NSObject, WKNavigationDelegate {
    
}
