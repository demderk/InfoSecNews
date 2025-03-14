//
//  WebVoyager.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 28.02.2025.
//

import Foundation
import WebKit

typealias ParseStrategy = (String) -> [any NewsBehavior]

protocol DataVoyager {
    associatedtype RemoteData
    
    func fetch(url: URL) async -> Result<RemoteData, RemoteError>
}

class WebVoyager: DataVoyager {
    
    var url: URL = URL(string: "https://en.wikipedia.org/wiki/Duck")!
    var moduleName: String = "WebVoyager"
    var webKit: WebKitHead = WebKitHead()
    var htmlBody: String?
    
    var requestTimeout: Duration = .seconds(10)
    
    var bussy: Bool = false
    
    init() {
        webKitSetup()
    }
    
    let mainSemaphore = Semaphore(count: 1)
    
    @MainActor
    func fetch(url: URL) async -> Result<String, RemoteError> {
        await mainSemaphore.wait()
        let result: Result<String, RemoteError> = await withCheckedContinuation { continuation in
            var isCancelled = false
            var isFinished = false
            webKit.load(url: url)
            webKit.singleLoadAction(action: WebAction({ html, _ in
                guard !isCancelled else { return }
                
                guard let html = html else {
                    isFinished = true
                    continuation.resume(returning: .failure(.badResult))
                    return
                }
                isFinished = true
                continuation.resume(returning: .success(html))
                return
            }))
            Task {
                try? await Task.sleep(for: requestTimeout)
                guard !isFinished else { return }
                isCancelled = true
                continuation.resume(returning: .failure(.timeout))
            }
        }
        await mainSemaphore.signal()
        return result
    }

    func webKitSetup() {
        webKit.subscribeDOMUpdateAction(action: WebAction(DOMUpdated))
        webKit.subscribeLoadFinished(action: WebAction(loadFinished))
    }
    
    func loadFinished(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
    
    func DOMUpdated(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
}
