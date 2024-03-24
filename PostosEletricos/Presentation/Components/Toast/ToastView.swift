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
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.8))
            .foregroundColor(.black)
            .cornerRadius(20)
            .shadow(radius: 2)
    }
}
