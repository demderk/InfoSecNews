//
//  WebView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI
import WebKit
import AppKit

class WKWebViewNavigationCoordinator<TC: NewsModule>: NSObject, WKNavigationDelegate {
    @ObservedObject var parentVM: TC
    
    init(parentVM: ObservedObject<TC>) {
        self._parentVM = parentVM
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [self] result, error in
            if let html = result as? String {
                parentVM.loadFinished(webView)
                parentVM.htmlBody = html
            }
        }
        
    }
}

struct WebView<T: NewsModule>: NSViewRepresentable {
    @ObservedObject var webModule: T
    
    private var webKitConfig: WKWebViewConfiguration!
    private var webView: WKWebView!
    private var coordinator: WKWebViewNavigationCoordinator<T>!
    
    func makeNSView(context: Context) -> WKWebView {
        print("DRAW: \(ObjectIdentifier(webView))")
        return webView
    }
    init(_ module: T) {
        webModule = module
                
        if module.webView == nil {
            let cord = makeCoordinator()
            coordinator = cord
            module.prepareWebView(coordinator: cord)
            webView = module.webView
            webView.load(URLRequest(url: webModule.url))
        } else {
            webView = module.webView
        }
        
//
//        print("INIT: \(ObjectIdentifier(webView))")

        
        
//        if module.webView == nil {
//            webView = WKWebView()
//            webView.enableNotificationCenter(onMessage: { [self] html, _ in
//                webModule.htmlBody = html
//                webModule.DOMUpdated()
//            })
//            module.webView = webView
//            webView.load(URLRequest(url: webModule.url))
//            coordinator = makeCoordinator()
//            webView.navigationDelegate = coordinator
//        } else {
//            webView = module.webView
//        }
        
        
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }

    func makeCoordinator() -> WKWebViewNavigationCoordinator<T> {
        WKWebViewNavigationCoordinator(parentVM: _webModule)
    }
}

class WebKitStaticHostCoordinator: NSObject, WKNavigationDelegate {
    
}
