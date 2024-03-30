//
//  View+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import SwiftUI

extension View {

    // MARK: Toast

    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}

extension View {

    // MARK: UIEdgeInsets

    func safeArea() -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let safeArea = window.windows.first?.safeAreaInsets
        else { return .zero }

        return safeArea
    }
}
