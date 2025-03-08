//
//  NewsProvider.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 09.03.2025.
//
import Foundation

protocol NewsProvider {
    associatedtype NewsItem: NewsBehavior
    
    var baseUrl: URL { get }
    var moduleName: String { get }
    
    var pageNumber: Int { get set }
    var currentUrlString: URL { get }
    var nextUrlString: URL { get }
    
    func parse(input: String) -> [NewsItem]
}
