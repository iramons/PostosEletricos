//
//  MapHeaderView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import Lottie

struct MapHeaderView: View {

    var animation: Namespace.ID

    var body: some View {
        HStack {
            LottieView(animation: .named("splash-anim"))
                .looping()
                .resizable()
                .frame(width: 60, height: 60)
                .matchedGeometryEffect(id: "chargeStationAnimID", in: animation)

            Text("Postos Elétricos")
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.regular)
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 70)
        .padding(.horizontal)
        .background(.white)
    }
}
