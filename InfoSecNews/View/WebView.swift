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
    
    private var webKitConfig: WKWebViewConfiguration!
    private var webView: WKWebView!
    private var coordinator: Coordinator<T>!
    private var scriptHandler: ScriptHandler<T>!
    
    func makeNSView(context: Context) -> WKWebView {
        print("DRAW: \(ObjectIdentifier(webView))")
        return webView
    }
    init(_ module: T) {
        webModule = module
        let wkconfig = WKWebViewConfiguration()
        webKitConfig = wkconfig
        
        if module.webView == nil {
            webView = WKWebView(frame: .zero, configuration: webKitConfig)
            module.webView = webView
            scriptHandler = ScriptHandler(parentVM: module, parentWKView: webView)
            wkconfig.userContentController.add(scriptHandler, name: "notificationCenter")
            webView.load(URLRequest(url: webModule.url))
        } else {
            webView = module.webView
        }
        
        coordinator = makeCoordinator()
        
        webView.navigationDelegate = coordinator
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator<T> {
        Coordinator(parentVM: _webModule)
    }
    
    
    class ScriptHandler<TS: NewsModule>: NSObject, WKScriptMessageHandler {
        @ObservedObject var parentVM: TS
        private let webKit: WKWebView
        
        init(parentVM: TS, parentWKView: WKWebView) {
            self.parentVM = parentVM
            self.webKit = parentWKView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            webKit.evaluateJavaScript("document.documentElement.innerHTML") { [self] result, error in
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
        }
    }
}

class WebKitStaticHostCoordinator: NSObject, WKNavigationDelegate {
    
}
