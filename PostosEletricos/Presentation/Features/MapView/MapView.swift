//
//  MapView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI
import Moya
import CombineMoya
import GooglePlaces

// MARK: MapView

struct MapView: View {
    
    @ObservedObject private var viewModel = MapViewModel()
    
    var body: some View { 
        VStack {
            MapHeaderView()
            
            ZStack {
                Map(
                    position: $viewModel.cameraPosition,
                    content: {
                        ForEach(viewModel.items, id: \.self) { item in
                            let placemark = item.placemark
                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        }
                    }
                )
                .mapControls {
                    MapCompass()
                    MapPitchToggle()
                    MapUserLocationButton()
                }
            }
        }
        .background(.blue)
        .task {
            try? await viewModel.locationService2.requestUserAuthorization()
            try? await viewModel.locationService2.startCurrentLocationUpdates()

        }
//        .onAppear() {
//            viewModel.getLocationUpdates()
//        }
    }
}

#Preview {
    MapView()
}
