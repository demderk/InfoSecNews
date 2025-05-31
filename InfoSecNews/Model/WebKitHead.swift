//
//  WebKitHead.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 25.02.2025.
//

import WebKit

class WKWebViewNavigationCoordinator: NSObject, WKNavigationDelegate {
    var finished: WebAction

    init(finished: WebAction) {
        self.finished = finished
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [weak self] result, _ in
            guard let self = self else { return }
            if let html = result as? String {
                finished.action(html, webView)
            }
        }
    }
}

class WebKitHead {
    private(set) var webView: WKWebView = .init()
    private(set) var coordinator: WKWebViewNavigationCoordinator!

    private var loadFinisedActions: [WebAction] = []

    private var loadFinisedSubscribers: [WebAction] = []
    private var DOMUpdatedSubscribers: [WebAction] = []

    init() {
        coordinator = WKWebViewNavigationCoordinator(finished: WebAction(executeFinishActions))
        webView.navigationDelegate = coordinator
        webView.enableNotificationCenter(onMessage: { [weak self] html, web in
            guard let self = self else { return }
            for DOMUpdatedAction in DOMUpdatedSubscribers {
                DOMUpdatedAction.action(html, web)
            }
        })
    }

    convenience init(preloadedUrl: URL) {
        self.init()
        webView.load(URLRequest(url: preloadedUrl))
    }

    private func executeFinishActions(html: String?, _ webView: WKWebView) {
        WKNotificationCenter.subscribe(webView)

        for n in loadFinisedActions {
            loadFinisedActions.removeAll(where: {
                if $0 == n {
                    n.action(html, webView)
                    return true
                }
                return false
            })
        }

        for loadFinisedSubscriber in loadFinisedSubscribers {
            loadFinisedSubscriber.action(html, webView)
        }
    }

    func subscribeLoadFinished(action: WebAction) {
        loadFinisedSubscribers.append(action)
    }

    func singleLoadAction(action: WebAction) {
        loadFinisedActions.append(action)
    }

    func subscribeDOMUpdateAction(action: WebAction) {
        DOMUpdatedSubscribers.append(action)
    }

    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
}
