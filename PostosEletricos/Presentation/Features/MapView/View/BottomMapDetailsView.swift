//
//  BottomMapDetailsView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/03/24.
//

import Foundation
import SwiftUI
import MapKit

struct BottomMapDetailsView: View {
    
    var selection: MKMapItem
    var isRoutePresenting: Bool
    var action: (() -> Void)

    var body: some View {
        VStack {
            Text("Endereço")
                .multilineTextAlignment(.leading)
                .font(.headline)
                .foregroundStyle(.black)
                .padding(.top, 12)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(selection.placemark.name ?? "SEMNOME-1")
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(
                action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    action()
                },
                label: {
                    Text(isRoutePresenting ? "Remover rota" : "Mostrar rota")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                }
            )
            .background(isRoutePresenting ? .red : .indigo)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .trailing)

            LocationPreviewLookAroundView(selectedResult: selection)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(.white)
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}

#Preview {
    BottomMapDetailsView(selection: MKMapItem(), isRoutePresenting: false, action: {})
}
