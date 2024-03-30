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
    @State var animateContent: Bool = false
    @Namespace var animation

    let animationTiming: Double = 0.65

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
            MapView(withAnimation: animation)
                .offset(y: animateContent ? 0 : proxy.size.height - 70)
        }
        .transition(.identity)
        .ignoresSafeArea(.container, edges: .all)
        .onAppear {
            if !animateContent {
                withAnimation(.easeInOut(duration: animationTiming)) {
                    animateContent = true
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
                .shadow(radius: 4, x: 0, y: 8)
                .matchedGeometryEffect(id: "splashBackgroundAnimId", in: animation)

            VStack {
                LottieView(animation: .named("splash-anim"))
                    .looping()
                    .resizable()
                    .frame(width: 100, height: 100)
                    .matchedGeometryEffect(id: "splashLogoAnimId", in: animation)
            }
        }
        .ignoresSafeArea(.container, edges: .all)
    }
}

#Preview {
    AnimatedSplashView()
}
