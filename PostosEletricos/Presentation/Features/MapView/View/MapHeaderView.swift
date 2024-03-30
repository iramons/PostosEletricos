//
//  MapHeaderView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import Lottie

struct MapHeaderView: View {

    init(
        withAnimation animation: Namespace.ID,
        isLoading: Bool = false
    ) {
        self.animation = animation
        self.isLoading = isLoading
    }

    let animation: Namespace.ID
    @State var isLoading: Bool
    @State var canShowProgress: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.white)
                .shadow(radius: 4, x: 0, y: 8)
                .matchedGeometryEffect(id: "splashBackgroundAnimId", in: animation)
                .frame(height: 70 + safeArea().top)

            VStack {
                HStack(alignment: .center) {
                    LottieView(animation: .named("splash-anim"))
                        .looping()
                        .resizable()
                        .frame(width: 50, height: 50)
                        .matchedGeometryEffect(id: "splashLogoAnimId", in: animation)

                    Text("Postos Elétricos")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundStyle(.black)
                }
                .padding(8)

                if canShowProgress, isLoading {
                    HProgressView()
                }
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    canShowProgress.toggle()
                }
            }
        }
    }
}

#Preview {
    @Namespace var animation

    return VStack {
        MapHeaderView(withAnimation: animation)
        Spacer()
    }
}
