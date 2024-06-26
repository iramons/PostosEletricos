//
//  HProgressView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import SwiftUI

struct HProgressView: View {

    @State private var isAnimating = false
    var show: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(Color.gray.opacity(0.3))

                // Animated progress bar
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.yellow)
                    .frame(width: geometry.size.width / 3)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width / 8)
            }
        }
        .frame(height: 2)
        .opacity(show ? 1 : 0)
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating.toggle()
            }
        }
    }
}

#Preview {
    HProgressView()
        .padding()
}
