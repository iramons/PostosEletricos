//
//  AnimatedSplashView.swift
//  PostosEletricos
//
//  Created by Sportheca Brasil on 29/03/24.
//

import SwiftUI
import Lottie

struct AnimatedSplashView<T:View>: View {

    init(
        @ViewBuilder content: @escaping () -> T,
        onAnimatedEnd: @escaping () -> Void
    ) {
        self.content = content()
        self.onAnimatedEnd = onAnimatedEnd
    }

    var content: T
    var onAnimatedEnd: ()->()
    let animationTiming: Double = 0.65
    @State var startAnimation: Bool = false
    @State var animateContent: Bool = false
    @Namespace var animation

    var body: some View {
        VStack(spacing: 0) {
            if startAnimation {
                GeometryReader { proxy in
                    VStack(spacing: 0) {
                        MapHeaderView(withAnimation: animation, isLoading: true)
                            .zIndex(1)

                        content
                            .offset(y: animateContent ? 0 : (proxy.size.height - (70 + safeArea().top)))
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
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

                DispatchQueue.main.asyncAfter(deadline: .now() + (animationTiming - 0.05)) {
                    withAnimation(.easeInOut(duration: animationTiming)) {
                        onAnimatedEnd()
                    }
                }
            }
        }
    }
}

#Preview {
    AnimatedSplashView() {
        MapView()
    } onAnimatedEnd: {
        
    }
}

extension View {
    func safeArea() -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let safeArea = window.windows.first?.safeAreaInsets
        else { return .zero }

         return safeArea
    }
}
