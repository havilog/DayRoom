//
//  Shake+.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/11.
//

import SwiftUI

struct Shake<Content: View>: View {
    /// Set to true in order to animate
    @Binding var shake: Bool
    /// How many times the content will animate back and forth
    var repeatCount = 2
    /// Duration in seconds
    var duration = 0.3
    /// Range in pixels to go back and forth
    var offsetRange = 3.0

    @ViewBuilder let content: Content
    var onCompletion: (() -> Void)?

    @State private var xOffset = 0.0

    var body: some View {
        content
            .offset(x: xOffset)
            .onChange(of: shake) { shouldShake in
                guard shouldShake else { return }
                Task {
                    await animate()
                    shake = false
                    onCompletion?()
                }
            }
    }

    // Obs: some of factors must be 1.0.
    private func animate() async {
        let factor1 = 0.9
        let eachDuration = duration * factor1 / CGFloat(repeatCount)
        for _ in 0..<repeatCount {
            await backAndForthAnimation(duration: eachDuration, offset: offsetRange)
        }

        let factor2 = 0.1
        await animate(duration: duration * factor2) {
            xOffset = 0.0
        }
    }

    private func backAndForthAnimation(duration: CGFloat, offset: CGFloat) async {
        let halfDuration = duration / 2
        await animate(duration: halfDuration) {
            self.xOffset = offset
        }

        await animate(duration: halfDuration) {
            self.xOffset = -offset
        }
    }
}

extension View {
    func shake(_ shake: Binding<Bool>,
               repeatCount: Int = 2,
               duration: CGFloat = 0.3,
               offsetRange: CGFloat = 5,
               onCompletion: (() -> Void)? = nil) -> some View {
        Shake(shake: shake,
              repeatCount: repeatCount,
              duration: duration,
              offsetRange: offsetRange) {
            self
        } onCompletion: {
            onCompletion?()
        }
    }

    func animate(duration: CGFloat, _ execute: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                execute()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
}
