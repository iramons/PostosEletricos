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
    var isLoading: Bool
    @State var canShowProgress: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 8)
                .matchedGeometryEffect(id: "splashBackgroundAnimId", in: animation)

            VStack(spacing: .zero) {
                HStack(alignment: .bottom) {
                    LottieView(animation: .named("splash-anim"))
                        .looping()
                        .resizable()
                        .frame(width: 45, height: 45)
                        .matchedGeometryEffect(id: "splashLogoAnimId", in: animation)

                    Text("Postos Elétricos")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundStyle(.black)
                }
                .padding(8)

                HProgressView(show: isLoading)
                    .opacity(canShowProgress ? 1 : 0)
            }
        }
        .frame(height: 60)
        .onAppear {
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
