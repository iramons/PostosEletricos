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

    @ObservedObject var viewModel: MapViewModel

    var animation: Namespace.ID

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            LottieView(animation: .named("splash-anim"))
                .looping()
                .resizable()
                .frame(width: 100, height: 100)
                .matchedGeometryEffect(id: "chargeStationAnimID", in: animation)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
