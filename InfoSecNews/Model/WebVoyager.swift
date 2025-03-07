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
    
    func fetch(url: URL) async -> Result<RemoteData, DataVoyagerError>
}

enum DataVoyagerError: Error {
    case badResult
}

class WebVoyager: DataVoyager {
    
    var url: URL = URL(string: "https://en.wikipedia.org/wiki/Duck")!
    var moduleName: String = "WebVoyager"
    var webKit: WebKitHead = WebKitHead()
    var htmlBody: String?
    
    var bussy: Bool = false
    
    init() {
        webKitSetup()
    }
    
    let mainSemaphore = Semaphore(count: 1)
    
    @MainActor
    func fetch(url: URL) async -> Result<String, DataVoyagerError> {
        await mainSemaphore.wait()
        let result: Result<String, DataVoyagerError> = await withCheckedContinuation { continuation in
            webKit.load(url: url)
            webKit.singleLoadAction { html, _ in
                guard let html = html else {
                    continuation.resume(returning: .failure(.badResult))
                    return
                }
                continuation.resume(returning: .success(html))
                return
            }
        }
        await mainSemaphore.signal()
        return result
    }

    func webKitSetup() {
        webKit.subscribeDOMUpdateAction(action: DOMUpdated)
        webKit.subscribeLoadFinished(action: loadFinished)
    }
    
    func loadFinished(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
    
    func DOMUpdated(_ html: String?, _ webView: WKWebView) {
        htmlBody = html
    }
}
