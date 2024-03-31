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
    @Namespace var animation

    let animationTiming: Double = 0.5

    var body: some View {
        VStack(spacing: .zero) {
            if startAnimation {
                contentScreen
            } else {
                launchScreen
            }
        }
        .onAppear {
            if !startAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: animationTiming)) {
                        startAnimation.toggle()
                    }
                }
            }
        }
    }
}

// MARK: Content

extension AnimatedSplashView {
    var contentScreen: some View {
        GeometryReader { proxy in
            MapView(animation: animation)
        }
        .transition(.identity)
    }
}

// MARK: LaunchScreen

extension AnimatedSplashView {
    var launchScreen: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 8)
                .matchedGeometryEffect(id: "splashBackgroundAnimId", in: animation)

            LottieView(animation: .named("splash-anim"))
                .looping()
                .resizable()
                .frame(width: 100, height: 100)
                .matchedGeometryEffect(id: "splashLogoAnimId", in: animation)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    AnimatedSplashView()
}
