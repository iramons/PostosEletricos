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
    
    @State private var shouldShowDetails = false
        
    var body: some View {
        VStack(alignment: .center) {
            if shouldShowDetails {
                Text("Você")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .padding(8)
                    .background(.white)
                    .cornerRadius(16)
                    .opacity(shouldShowDetails ? 1 : 0)
                    .shadow(radius: 4)
            }
            
            LottieView(animation: .named("user-location-anim"))
                .looping()
                .resizable()
                .frame(width: 50, height: 50)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shouldShowDetails.toggle()
            }
        }
    }
}

#Preview {
    MapUserAnnotation()
}
