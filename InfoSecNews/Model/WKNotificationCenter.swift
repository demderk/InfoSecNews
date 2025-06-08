//
//  WKNotificationCenter.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 23.02.2025.
//

import Foundation
import SwiftUICore
import WebKit

class WKNotificationCenter: NSObject, WKScriptMessageHandler {
    private let webKit: WKWebView

    private var arrived: ((String, WKWebView) -> Void)?

    init(_ webKit: WKWebView, arrived: ((String, WKWebView) -> Void)? = nil) {
        self.arrived = arrived
        self.webKit = webKit
    }

    func userContentController(
        _: WKUserContentController,
        didReceive _: WKScriptMessage
    ) {
        webKit.evaluateJavaScript("document.documentElement.innerHTML") { [weak self] result, _ in
            guard let self = self else { return }
            if let html = result as? String {
                arrived?(html, webKit)
            }
        }
    }

    static func subscribe(_ webView: WKWebView) {
        let preactions = """
        const target = document;
        const config = {childList: true, subtree: true};
        var count = 2


        const callback = function(mutationsList, observer) {
            window.webkit.messageHandlers.notificationCenter.postMessage("changed")
        };

        const observer = new MutationObserver(callback);
        observer.observe(target, config);
        """

        webView.evaluateJavaScript(preactions)
    }
}

extension WKWebView {
    func enableNotificationCenter(
        onMessage: @escaping ((String, WKWebView) -> Void)
    ) {
//        WKNotificationCenter.subscribe(self)
        configuration.userContentController.add(
            WKNotificationCenter(self, arrived: onMessage),
            name: "notificationCenter"
        )
    }
}
