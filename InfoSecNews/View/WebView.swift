//
//  WebView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI
import WebKit
import AppKit

struct WebView<T: NewsModule>: NSViewRepresentable {
    @ObservedObject var webModule: T
    
    private let webKitConfig: WKWebViewConfiguration
    private var webView: WKWebView
    private var coordinator: Coordinator<T>?
    private var scriptHandler: ScriptHandler<T>!
    
    func makeNSView(context: Context) -> WKWebView {
        return webView
    }
    init(_ module: ObservedObject<T>) {
        _webModule = module
        let wkconfig = WKWebViewConfiguration()
        webKitConfig = wkconfig
        webView = WKWebView(frame: .zero, configuration: webKitConfig)
        scriptHandler = ScriptHandler(parentVM: module, parentWKView: webView)
        wkconfig.userContentController.add(scriptHandler, name: "notificationCenter")
        coordinator = makeCoordinator()
        
        webView.navigationDelegate = coordinator
        webView.load(URLRequest(url: webModule.url))
    }
    
//    func load() {
//        webView.navigationDelegate = coordinator
//        webView.load(URLRequest(url: webModule.url))
//    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator<T> {
        Coordinator(parentVM: _webModule)
    }
    
    
    class ScriptHandler<TS: NewsModule>: NSObject, WKScriptMessageHandler {
        @ObservedObject var parentVM: TS
        private let webKit: WKWebView
        
        init(parentVM: ObservedObject<TS>, parentWKView: WKWebView) {
            self._parentVM = parentVM
            self.webKit = parentWKView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("notification")
            webKit.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [self] result, error in
                if let html = result as? String {
                    parentVM.htmlBody = html
                }
                parentVM.DOMUpdated()
            }
        }
    }
    
    class Coordinator<TC: NewsModule>: NSObject, WKNavigationDelegate {
        @ObservedObject var parentVM: TC
        
        init(parentVM: ObservedObject<TC>) {
            self._parentVM = parentVM
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [self] result, error in
                if let html = result as? String {
                    parentVM.loadFinished(webView)
//                    parentVM.htmlBody = html
                }
            }
            print("Finished")
        }
    }
}

class WebKitStaticHostCoordinator: NSObject, WKNavigationDelegate {
    
}
