//
//  MessageBubble.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 07.05.2025.
//

// Source: https://gist.github.com/navsing/21373a82146747e06eef87b5645d8663
// Thanks!

import AppKit
import SwiftUI

// swiftlint:disable line_length
struct MessageBubble: Shape {
    var isUserMessage: Bool
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        let bezierPath = NSBezierPath()
        if !isUserMessage {
            bezierPath.move(to: CGPoint(x: 20, y: height))
            bezierPath.line(to: CGPoint(x: width - 15, y: height))
            bezierPath.curve(to: CGPoint(x: width, y: height - 15), controlPoint1: CGPoint(x: width - 8, y: height), controlPoint2: CGPoint(x: width, y: height - 8))
            bezierPath.line(to: CGPoint(x: width, y: 15))
            bezierPath.curve(to: CGPoint(x: width - 15, y: 0), controlPoint1: CGPoint(x: width, y: 8), controlPoint2: CGPoint(x: width - 8, y: 0))
            bezierPath.line(to: CGPoint(x: 20, y: 0))
            bezierPath.curve(to: CGPoint(x: 5, y: 15), controlPoint1: CGPoint(x: 12, y: 0), controlPoint2: CGPoint(x: 5, y: 8))
            bezierPath.line(to: CGPoint(x: 5, y: height - 10))
            bezierPath.curve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 5, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.line(to: CGPoint(x: -1, y: height))
            bezierPath.curve(to: CGPoint(x: 12, y: height - 4), controlPoint1: CGPoint(x: 4, y: height + 1), controlPoint2: CGPoint(x: 8, y: height - 1))
            bezierPath.curve(to: CGPoint(x: 20, y: height), controlPoint1: CGPoint(x: 15, y: height), controlPoint2: CGPoint(x: 20, y: height))
        } else {
            bezierPath.move(to: CGPoint(x: width - 20, y: height))
            bezierPath.line(to: CGPoint(x: 15, y: height))
            bezierPath.curve(to: CGPoint(x: 0, y: height - 15), controlPoint1: CGPoint(x: 8, y: height), controlPoint2: CGPoint(x: 0, y: height - 8))
            bezierPath.line(to: CGPoint(x: 0, y: 15))
            bezierPath.curve(to: CGPoint(x: 15, y: 0), controlPoint1: CGPoint(x: 0, y: 8), controlPoint2: CGPoint(x: 8, y: 0))
            bezierPath.line(to: CGPoint(x: width - 20, y: 0))
            bezierPath.curve(to: CGPoint(x: width - 5, y: 15), controlPoint1: CGPoint(x: width - 12, y: 0), controlPoint2: CGPoint(x: width - 5, y: 8))
            bezierPath.line(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.curve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 5, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
            bezierPath.line(to: CGPoint(x: width + 1, y: height))
            bezierPath.curve(to: CGPoint(x: width - 12, y: height - 4), controlPoint1: CGPoint(x: width - 4, y: height + 1), controlPoint2: CGPoint(x: width - 8, y: height - 1))
            bezierPath.curve(to: CGPoint(x: width - 20, y: height), controlPoint1: CGPoint(x: width - 15, y: height), controlPoint2: CGPoint(x: width - 20, y: height))
        }
        return Path(bezierPath.cgPath)
    }
}
// swiftlint:enable line_length
