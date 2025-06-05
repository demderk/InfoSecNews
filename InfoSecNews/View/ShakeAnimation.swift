//
//  ShakeAnimation.swift
//  LazyEncrypt
//
//  Created by Roman Zheglov on 05.03.2023.
//

// Source: https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/

import Foundation
import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 4
    var animatableData: CGFloat

    func effectValue(size _: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
