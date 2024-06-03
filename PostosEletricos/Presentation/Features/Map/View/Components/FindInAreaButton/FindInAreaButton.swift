//
//  FindInAreaButton.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 22/03/24.
//

import SwiftUI

struct FindInAreaButton: View {

    @State private var animate: Bool = false
    let action: (() -> Void)

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            withAnimation {
                animate.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate.toggle()
                }
            }

            action()
        }, label: {
            Text("Buscar nesta área")
        })
        .font(.custom("Roboto-Medium", size: 13))
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.thinMaterial)
        .foregroundStyle(.primary)
        .cornerRadius(26)
        .shadow(radius: 2)
        .scaleEffect(animate ? 1.2 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animate)
    }
}

#Preview {
    FindInAreaButton(action: {})
}
