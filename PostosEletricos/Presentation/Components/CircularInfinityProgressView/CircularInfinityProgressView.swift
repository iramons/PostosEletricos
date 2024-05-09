//
//  CircularInfinityProgressView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 04/05/24.
//

import Foundation
import SwiftUI

struct CircularInfinityProgressView: View {

    var strokeColor: Color = .accentColor
    var strokeWidth: CGFloat = 4
    var backgroundColor: Color = .black.opacity(0.1)
    var size: CGFloat = 20
    var padding: CGFloat = 8
    var indicatorFillPercent: CGFloat = 0.3
    var indicatorWidth: CGFloat = 4
    var autoreverses: Bool = false

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .stroke(backgroundColor, lineWidth: strokeWidth)
            .overlay(
                Circle()
                    .trim(from: 0, to: indicatorFillPercent)
                    .stroke(strokeColor, lineWidth: indicatorWidth)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            )
            .animation(.linear(duration: 1).repeatForever(autoreverses: autoreverses), value: isAnimating)
            .onAppear() {
                isAnimating = true
            }
            .frame(width: size, height: size)
            .padding(padding)
    }
}
