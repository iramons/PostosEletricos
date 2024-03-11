//
//  MapUserAnnotation.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import SwiftUI
import Lottie

struct MapUserAnnotation: View {
    
    @State private var showTitle = true
        
    var body: some View {
        VStack(alignment: .center) {
            Text("Você")
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundStyle(.blue)
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .background(.white)
                .cornerRadius(16)
                .opacity(showTitle ? 0 : 1)
                .shadow(radius: 4)
                .zIndex(1)
            
            LottieView(animation: .named("user-location-anim"))
                .looping()
                .resizable()
                .frame(width: 50, height: 50)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showTitle.toggle()
                
                // TODO: Colocar clique no Mapa, fecha o alert
            }
        }
    }
    
    func hideTitle() {
        showTitle.toggle()
    }
}

#Preview {
    MapUserAnnotation()
}
