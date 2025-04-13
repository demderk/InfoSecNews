//
//  AppearanceEffectRenderer.swift
//  InfoSecNews
//
//  Created by Roman Zheglov on 03.03.2025.
//

import SwiftUI

struct AppearanceEffectRenderer: TextRenderer, Animatable {
    
    var elapsedTime: TimeInterval

    var totalDuration: TimeInterval

    var animatableData: Double {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        
        let delay = totalDuration / TimeInterval(layout.count) / 4
                
        let perElement = totalDuration / TimeInterval(layout.count) * 4
        
        for (i, item) in layout.enumerated() {
            
            var copy = ctx
            let timeOffest = delay * TimeInterval(i)
            let elementTime = max(0, min(elapsedTime - timeOffest, perElement))
            
            let translateFactor = Spring(duration: perElement, bounce: 0.3)
                .value(
                    fromValue: -item.typographicBounds.descent * 2,
                    toValue: 0,
                    initialVelocity: -0.3,
                    time: elementTime)
            
//            let scaleFactor = Spring(duration: perElement, bounce: 0.3)
//                .value(
//                    fromValue: 0.9,
//                    toValue: 1,
//                    initialVelocity: -0,
//                    time: elementTime)
            
            let opacityFactor = Spring(duration: perElement, bounce: 0.3)
                .value(
                    fromValue: 0,
                    toValue: 1,
                    initialVelocity: -0.3,
                    time: elementTime)
            
            copy.opacity = opacityFactor
//            copy.scaleBy(x: scaleFactor, y: scaleFactor)
            copy.translateBy(x: -translateFactor, y: translateFactor)
            
            copy.draw(item)
            
        }
    }
}

struct AppearanceTransition: Transition {
    static var properties: TransitionProperties {
        TransitionProperties(hasMotion: true)
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        let duration = 1.0
        let elapsedTime = phase.isIdentity ? duration : 0
        let renderer = AppearanceEffectRenderer(
            elapsedTime: elapsedTime,
            totalDuration: duration
        )

        content.transaction { transaction in
            // Force the animation of `elapsedTime` to pace linearly and
            // drive per-glyph springs based on its value.
            if !transaction.disablesAnimations {
                transaction.animation = .linear(duration: duration)
            }
        } body: { view in
            if #available(macOS 15.0, *) {
                view.textRenderer(renderer)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

extension Transition {
    var asAnyTransition: AnyTransition {
        AnyTransition(self)
    }
}
