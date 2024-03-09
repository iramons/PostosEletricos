//
//  MapHeaderView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI

struct MapHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "ev.charger")
                .imageScale(.large)
                .foregroundStyle(.yellow)
            
            Text("Postos Elétricos")
                .font(.title2)
        }
        .background(.blue)
    }
}

#Preview {
    MapHeaderView()
}
