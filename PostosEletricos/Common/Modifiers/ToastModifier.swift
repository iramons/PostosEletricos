//
//  ToastModifier.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import SwiftUI

struct ToastModifier: ViewModifier {

    @Binding var isShowing: Bool
    var message: String

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if isShowing {
                ToastView(message: message)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 0.4)) {
                                isShowing.toggle()
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {}
    .toast(isShowing: .constant(true), message: "Message")
}
