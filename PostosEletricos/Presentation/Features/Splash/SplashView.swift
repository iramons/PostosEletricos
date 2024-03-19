//
//  SplashView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 19/03/24.
//

import Foundation
import SwiftUI
import Lottie

struct SplashView: View {
    var body: some View {
        
        Color.white
            .ignoresSafeArea()
        
        LottieView(animation: .named("splash-anim"))
            .looping()
            .resizable()
            .frame(width: 100, height: 100)
    }
}
