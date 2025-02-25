//
//  SecurityMediaNewsModule.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 10.02.2025.
//
import Foundation
import SwiftSoup
import WebKit
import Combine

final class SecurityMediaNewsModule: NewsModule {
    var webKit: WebKitHead = WebKitHead()
    
    var newsCollection: [NewsItem] = []
    
    @Published var url: URL = URL(string: "https://securitymedia.org/news/")!
    @Published var moduleName: String = "securitymedia.org"
    @Published var htmlBody: String? {
        didSet {
            try! pull()
        }
    }
        
    init() {
        webKitSetup()
    }
    
    private var preAction: String { """
    const SMtarget = document;
    const SMconfig = {childList: true, subtree: true};
    var SMcount = 2

    window.scrollTo(0,0);
    window.scrollTo(0,document.body.scrollHeight-300);


    const SMPreloadCallback = function(mutationsList, observer) {
        if (SMcount > 0) {
            window.scrollTo(0,0);
            window.scrollTo(0,document.body.scrollHeight-300);
            SMcount--;
        } else {
            observer.disconnect()
        }
    };

    const SMPreload = new MutationObserver(SMPreloadCallback);
    SMPreload.observe(SMtarget, SMconfig);
    """
    }
    
    func fetch() throws -> [NewsItem] {
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
            
            news.append(NewsItem(source: moduleName, title: newsTitle.trimmingCharacters(in: .whitespaces), date: newsDate, short: newsShort.trimmingCharacters(in: .whitespaces)))
        }
        
        return news
    }
        
    func loadFinished(_ html: String?, _ webView: WKWebView) {
        webView.evaluateJavaScript(preAction)
        htmlBody = html
    }
}
