//
//  PlaceAnnotationView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct PlaceAnnotationView: View {
    
    @State var showTitle = false
        
    let title: String
    
    var onTap: ((_ isExpanded: Bool) -> Void)
    
    var onShowRouteButtonTap: (() -> Void)

    var body: some View {
        VStack(spacing: 4) {
            VStack {
                Text("Endereço")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .padding(.horizontal)
                    .background(.blue)
                
                Text("\(title)")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                
                Button(
                    action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onShowRouteButtonTap()
                    },
                    label: {
                        Text("Mostrar rota")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(.indigo)
                            .cornerRadius(12)
                    }
                )
                .padding(.bottom, 8)
            }
            .background(.white)
            .cornerRadius(16)
            .opacity(showTitle ? 1 : 0)
            .shadow(radius: 4)
            
            Image("marker8")
                .resizable()
                .frame(width: 50, height: 50)
                .shadow(radius: 4)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showTitle.toggle()
                onTap(showTitle)
                // TODO: Colocar clique no Mapa, fecha o alert
            }
        }
    }
}

#Preview {
    PlaceAnnotationView(
        title: "Title",
        onTap: { _ in },
        onShowRouteButtonTap: {}
    )
}
