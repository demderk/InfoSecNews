//
//  SecurityMediaNewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//
import Foundation
import SwiftSoup

@MainActor
class SecurityMediaNewsModule: NewsModule, ObservableObject {
    var webWindow: WebView
    
    var url: URL = URL(string: "https://securitymedia.org/news/")!
    var windowID: String = "securitymedia-web"
    var moduleName: String = "securitymedia.org"
    
    var htmlBody: String? { webWindow.vm.htmlContent }
    
    var webVM = WebViewVM()
    
    let preAction: String = """
    const target = document;
    const config = {childList: true, subtree: true};
    var count = 2

    window.scrollTo(0,0);
    window.scrollTo(0,document.body.scrollHeight-300);


    const callback = function(mutationsList, observer) {
        window.webkit.messageHandlers.notificationCenter.postMessage("changed")
        if (count > 0) {
            window.scrollTo(0,0);
            window.scrollTo(0,document.body.scrollHeight-300);
            count--;
        } else {
            
        }
    };

    const observer = new MutationObserver(callback);
    observer.observe(target, config);
    """
    
    init() {
        print("Inited SCMM")
        webVM.onLoadFinished = { [preAction] wk in
            wk.evaluateJavaScript(preAction)
        }
        
        webWindow = WebView(url: url, vm: webVM)
        webWindow.load()
    }
    
    func parse() throws -> [NewsItem] {
        guard let htmlBody = htmlBody else {
            return []
        }
        
        let htDoc = try SwiftSoup.parse(htmlBody)
        
        let x = try htDoc.select("div.col-md-8")
        
        var news: [NewsItem] = []
        
        for item in x {
            var newsTitle: String?
            var newsDate: Date?
            var newsShort: String?
            
            if let title = try? item.select(".h4").text() {
                newsTitle = title
            }
            
            if let date = try? item.select(".date_time").text() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                newsDate = dateFormatter.date(from: date)
            }
            
            if let short = try? item.select("a").first() {
                newsShort = short.textNodes().last?.text()
            }
            
            if newsTitle?.isEmpty ?? true,
               newsDate == nil,
               newsShort?.isEmpty ?? true
            {
                continue
            }
            
            guard let newsTitle = newsTitle, let newsDate = newsDate, let newsShort = newsShort else {
                continue
            }
            
            news.append(NewsItem(title: newsTitle, date: newsDate, short: newsShort))
        }
        
        return news
    }
    
    
}
