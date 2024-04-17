//
//  AnimatedSplashView.swift
//  PostosEletricos
//
//  Created by Sportheca Brasil on 29/03/24.
//

import SwiftUI
import Lottie

struct AnimatedSplashView: View {

    @State var startAnimation: Bool = false

    var body: some View {
        VStack(spacing: .zero) {
            if startAnimation {
                MapView()
            } else {
                launchScreen
            }
        }
        .onAppear {
            if !startAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeIn) {
                        startAnimation.toggle()
                    }
                }
            }
        }
    }
}

// MARK: LaunchScreen

extension AnimatedSplashView {
    var launchScreen: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 8)

            LottieView(animation: .named("splash-anim"))
                .looping()
                .resizable()
                .frame(width: 100, height: 100)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    AnimatedSplashView()
}
