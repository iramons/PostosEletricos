//
//  FindInAreaButton.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 22/03/24.
//

import SwiftUI

struct FindInAreaButton: View {

    let onTap: (() -> Void)

    @State private var animate: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            withAnimation {
                animate.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate.toggle()
                }
            }

            onTap()
        }, label: {
            Text("Buscar nesta área")
        })
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(colorScheme == .light ? .white : .darkGray)
        .cornerRadius(26)
        .shadow(radius: 3)
        .scaleEffect(animate ? 1.2 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animate)
    }
}

#Preview {
    FindInAreaButton(onTap: {})
}
