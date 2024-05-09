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
            }
        }
    }
}
