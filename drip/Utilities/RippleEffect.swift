//
//  RippleEffect.swift
//  drip
//
//  SwiftUI modifiers for applying ripple effects during image processing.
//

import SwiftUI

/// A modifier that applies a ripple effect using the Metal shader.
struct RippleModifier: ViewModifier {
    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval

    var amplitude: Double = 12
    var frequency: Double = 15
    var decay: Double = 8
    var speed: Double = 1200

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: CGSize(width: amplitude, height: amplitude),
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }
}

/// Single ripple effect that plays once when triggered.
/// Used as a visual segue during background removal.
struct RippleEffect<T: Equatable>: ViewModifier {
    var origin: CGPoint
    var trigger: T
    var duration: TimeInterval = 1.5

    func body(content: Content) -> some View {
        content.keyframeAnimator(
            initialValue: 0.0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration
            ))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}

extension View {
    /// Applies a single ripple effect when the trigger value changes.
    /// - Parameters:
    ///   - origin: The center point of the ripple effect.
    ///   - trigger: Value that triggers the ripple when it changes.
    func rippleEffect<T: Equatable>(at origin: CGPoint, trigger: T) -> some View {
        modifier(RippleEffect(origin: origin, trigger: trigger))
    }
}
