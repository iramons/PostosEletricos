//
//  MapHeaderView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI

struct MapHeaderView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Image("marker5")
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("Postos Elétricos")
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.regular)
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 60)
        .padding(.horizontal)
        .background(.white)
        .shadow(radius: 8)
    }
}

#Preview {
    MapHeaderView()
}
