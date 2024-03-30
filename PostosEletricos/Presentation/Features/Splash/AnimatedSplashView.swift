//
//  AnimatedSplashView.swift
//  PostosEletricos
//
//  Created by Sportheca Brasil on 29/03/24.
//

import SwiftUI
import Lottie

struct AnimatedSplashView: View {

    let animationTiming: Double = 0.65
    @State var startAnimation: Bool = false
    @State var animateContent: Bool = false
    @Namespace var animation

    var body: some View {
        VStack(spacing: 0) {
            if startAnimation {
                GeometryReader { proxy in
                    MapView(withAnimation: animation)
                        .offset(y: animateContent ? 0 : (proxy.size.height - (70 + safeArea().top)))
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
            } else {
                SplashView(withAnimation: animation)
            }
        }
        .onAppear {
            if !startAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: animationTiming)) {
                        startAnimation = true
                    }
                }
            }
        }
    }
}

#Preview {
    AnimatedSplashView()
}

extension View {
    func safeArea() -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let safeArea = window.windows.first?.safeAreaInsets
        else { return .zero }

         return safeArea
    }
}
