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
                            Marker(placemark.name ?? "", systemImage: "ev.charger", coordinate: placemark.coordinate)
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
                title: Text("Serviços de localização desabilitados"),
                message: Text("Para utilizar este App é necessário habilitar o serviço de localização! Por favor habilite a localização para o App PostosEletricos nos Ajustes do iPhone."),
                primaryButton: .default(Text("Ajustes")) {
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
