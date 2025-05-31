//
//  WebView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import AppKit
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    private var webKitHead: WebKitHead!

    func makeNSView(context _: Context) -> WKWebView {
        return webKitHead.webView
    }

    init(_ module: WebKitHead) {
        webKitHead = module
    }

    func updateNSView(_: WKWebView, context _: Context) {}

    func makeCoordinator() -> WKWebViewNavigationCoordinator {
        webKitHead.coordinator
    }
}

class WebKitStaticHostCoordinator: NSObject, WKNavigationDelegate {}
