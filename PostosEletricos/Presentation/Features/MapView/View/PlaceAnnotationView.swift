//
//  PlaceAnnotationView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import SwiftUI

struct PlaceAnnotationView: View {
  @State private var showTitle = true
  
  let title: String
  
  var body: some View {
    VStack(spacing: 4) {
        VStack(spacing: 0) {
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
        }
        .background(.white)
        .cornerRadius(16)
        .opacity(showTitle ? 0 : 1)
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
        // TODO: Colocar clique no Mapa, fecha o alert
      }
    }
  }
}
