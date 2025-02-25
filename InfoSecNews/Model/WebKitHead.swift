//
//  WebKitHead.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 25.02.2025.
//

import WebKit

typealias WebAction = (_ html: String?, _ webView: WKWebView) -> Void

class WKWebViewNavigationCoordinator: NSObject, WKNavigationDelegate {
    var finished: WebAction
    
    init(finished: @escaping WebAction) {
        self.finished = finished
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [self] result, error in
            if let html = result as? String {
                finished(html, webView)
            }
        }
    }
}

class WebKitHead {    
    private(set) var webView: WKWebView = WKWebView()
    private(set) var coordinator: WKWebViewNavigationCoordinator!
    
    private var loadFinisedActions: [WebAction] = []
    private var DOMUpdatedActions: [WebAction] = []
    
    init() {
        coordinator = WKWebViewNavigationCoordinator(finished: executeFinishActions)
        webView.navigationDelegate = coordinator
        webView.enableNotificationCenter(onMessage: {  [DOMUpdatedActions] html, wk in
            for DOMUpdatedAction in DOMUpdatedActions {
                DOMUpdatedAction(html, wk)
            }
        })
    }
    
    convenience init(preloadedUrl: URL) {
        self.init()
        webView.load(URLRequest(url: preloadedUrl))
    }
    
    private func executeFinishActions(html: String?, _ webView: WKWebView) {
        WKNotificationCenter.subscribe(webView)
        
        for loadFinisedAction in loadFinisedActions {
            loadFinisedAction(html, webView)
        }
    }
    
    func subscribeLoadAction(action: @escaping WebAction) {
        loadFinisedActions.append(action)
    }
    
    func subscribeDOMUpdateAction(action: @escaping WebAction) {
        DOMUpdatedActions.append(action)
    }
    
    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
}
