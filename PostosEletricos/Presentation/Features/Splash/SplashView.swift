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

    init(withAnimation animation: Namespace.ID) {
        self.animation = animation
    }

    let animation: Namespace.ID

    var body: some View {
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
    @Namespace var animation
    return SplashView(withAnimation: animation)
}
