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
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [weak self] result, _ in
            guard let self = self else { return }
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
    
    private var loadFinisedSubscribers: [WebAction] = []
    private var DOMUpdatedSubscribers: [WebAction] = []
    
    init() {
        coordinator = WKWebViewNavigationCoordinator(finished: executeFinishActions)
        webView.navigationDelegate = coordinator
        webView.enableNotificationCenter(onMessage: {  [weak self] html, web in
            guard let self = self else { return }
            for DOMUpdatedAction in DOMUpdatedSubscribers {
                DOMUpdatedAction(html, web)
            }
        })
    }
    
    convenience init(preloadedUrl: URL) {
        self.init()
        webView.load(URLRequest(url: preloadedUrl))
    }
    
    private func executeFinishActions(html: String?, _ webView: WKWebView) {
        WKNotificationCenter.subscribe(webView)
        
        for (n, loadFinisedAction) in loadFinisedActions.enumerated() {
            loadFinisedActions.remove(at: n)(html, webView)
        }
                
        for loadFinisedSubscriber in loadFinisedSubscribers {
            loadFinisedSubscriber(html, webView)
        }
    }
    
    func subscribeLoadFinished(action: @escaping WebAction) {
        loadFinisedSubscribers.append(action)
    }
    
    func singleLoadAction(action: @escaping WebAction) {
        loadFinisedActions.append(action)
    }
    
    func subscribeDOMUpdateAction(action: @escaping WebAction) {
        DOMUpdatedSubscribers.append(action)
    }
    
    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
}
