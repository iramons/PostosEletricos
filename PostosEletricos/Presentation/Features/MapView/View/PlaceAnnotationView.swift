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

    var body: some View {
        Image("charger")
            .resizable()
            .frame(width: 36, height: 50)
            .shadow(radius: 4)
    }
}

#Preview {
    PlaceAnnotationView()
}
