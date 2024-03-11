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
    
    @State var shouldShowDetails = false
        
    let title: String
    
    var onTap: ((_ isExpanded: Bool) -> Void)
    
    var onShowRouteButtonTap: (() -> Void)

    var body: some View {
        VStack(spacing: 4) {
            if shouldShowDetails {
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
                            withAnimation(.easeInOut) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                shouldShowDetails.toggle()
                                onShowRouteButtonTap()
                            }
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
                .opacity(shouldShowDetails ? 1 : 0)
                .cornerRadius(16)
                .shadow(radius: 4)
            }

            Image("marker4")
                .resizable()
                .frame(width: 36, height: 50)
                .shadow(radius: 4)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shouldShowDetails.toggle()
                onTap(shouldShowDetails)
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
