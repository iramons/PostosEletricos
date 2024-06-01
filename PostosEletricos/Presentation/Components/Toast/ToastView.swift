//
//  ToastView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.custom("Roboto-Medium", size: 16))
            .accessibilityLabel(message)
            .multilineTextAlignment(.center)
            .padding(16)
            .background(.orange.opacity(0.8))
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}
