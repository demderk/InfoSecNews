//
//  WebView.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.02.2025.
//

import SwiftUI
import WebKit
import AppKit

class WebViewVM: ObservableObject {
    @Published var htmlContent: String = ""
    
    @MainActor
    public var onLoadFinished: ((WKWebView) -> Void)?
    
    @MainActor
    public var onDOMUpdated: (() -> Void)?
}

struct WebView: NSViewRepresentable {
    let url: URL
    @ObservedObject var vm: WebViewVM = WebViewVM()
    
    private let webKitConfig: WKWebViewConfiguration
    private var webView: WKWebView
    private var coordinator: Coordinator?
    private var scriptHandler: ScriptHandler!
    
    func makeNSView(context: Context) -> WKWebView {
        return webView
    }
    init(url: URL, vm: WebViewVM) {
        print("Inited WKV")
        self.vm = vm
        let wkconfig = WKWebViewConfiguration()
        webKitConfig = wkconfig
        self.url = url
        webView = WKWebView(frame: .zero, configuration: webKitConfig)
        scriptHandler = ScriptHandler(parentVM: vm, parentWKView: webView)
        wkconfig.userContentController.add(scriptHandler, name: "notificationCenter")
        coordinator = makeCoordinator()
    }
    
    func load() {
        webView.navigationDelegate = coordinator
        webView.load(URLRequest(url: url))
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        print("!")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parentVM: vm)
    }
    
    
    class ScriptHandler: NSObject, WKScriptMessageHandler {
        @ObservedObject var parentVM: WebViewVM
        private let webKit: WKWebView
        
        init(parentVM: WebViewVM, parentWKView: WKWebView) {
            self.parentVM = parentVM
            self.webKit = parentWKView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            webKit.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [self] result, error in
                if let html = result as? String {
                    parentVM.htmlContent = "1"
                }
            }
            print("§11")
            print("§11")
            parentVM.onDOMUpdated?()
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject var parentVM: WebViewVM
        
        init(parentVM: WebViewVM) {
            self.parentVM = parentVM
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [self] result, error in
                if let html = result as? String {
                    parentVM.onLoadFinished?(webView)
                    parentVM.htmlContent = html
                }
            }
            print("Finished")
        }
    }
}

class WebKitStaticHostCoordinator: NSObject, WKNavigationDelegate {
    
}
