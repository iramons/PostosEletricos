//
//  FindInAreaButton.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 22/03/24.
//

import SwiftUI

struct FindInAreaButton: View {

    @State private var animate: Bool = false

    var isLoading: Bool = false {
        willSet {
            print("isLoading = \(isLoading)")
        }
    }

    var action: (() -> Void)?

    var body: some View {

        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            withAnimation {
                animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate = false
                }
            }

            action?()
        }, label: {

            HStack(spacing: 16) {
                Text("Buscar nesta área")

                if isLoading {
                    withAnimation {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.orange)
                    }
                }
            }

        })
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(26)
        .shadow(radius: 3)
        .scaleEffect(animate ? 1.2 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animate)
    }
}


#Preview {
    FindInAreaButton()
}