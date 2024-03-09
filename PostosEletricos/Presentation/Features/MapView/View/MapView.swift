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
            try? await viewModel.startCurrentLocationUpdates()
        }
        .alert(isPresented: $viewModel.showLocationServicesAlert) {
            Alert(
                title: Text("Location Services Disabled"),
                message: Text("To use this feature, please enable location services in your device settings."),
                primaryButton: .default(Text("Settings")) {
                    // Direct users to the app's settings
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    MapView()
}
