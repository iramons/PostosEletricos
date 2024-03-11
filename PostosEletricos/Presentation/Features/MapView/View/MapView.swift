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
import Lottie

// MARK: MapView

struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()
    
    @State var isAnnotationsDetailsExpanded = false
    
    var body: some View {
        VStack {
            MapHeaderView()
            
            Map(position: $viewModel.cameraPosition) {
                UserAnnotation {
                    MapUserAnnotation()
                }
                
                ForEach(viewModel.items, id: \.self) { item in
                    Annotation("", coordinate: item.placemark.coordinate) {
                        PlaceAnnotationView(
                            shouldShowDetails: isAnnotationsDetailsExpanded,
                            title: item.name ?? "",
                            onTap: { isExpanded in
                                isAnnotationsDetailsExpanded = isExpanded
                            },
                            onShowRouteButtonTap: {
                                if let originCoordinate = viewModel.location?.coordinate {
                                    viewModel.fetchRouteFrom(originCoordinate, to: item.placemark.coordinate)
                                }
                            }
                        )
                    }
                }
                
                if let route = viewModel.route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 8)
                }
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            .overlay(alignment: .bottom) {
                HStack {
                    if let travelTime = viewModel.travelTime {
                        Text("Tempo de viagem: \(travelTime)")
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.black)
                            .background(.white.opacity(0.7))
                            .cornerRadius(16)
                    }
                }
            }
        }
        .task {
            try? await viewModel.startCurrentLocationUpdates()
        }
        .alert(isPresented: $viewModel.showLocationServicesAlert) {
            Alert(
                title: Text("Serviços de localização desabilitados"),
                message: Text("Para utilizar este App é necessário habilitar o serviço de localização! Por favor habilite a localização para o App PostosEletricos nos Ajustes do iPhone."),
                primaryButton: .default(Text("Ajustes")) {
                    openiPhoneSettings()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: Private
    
    /// Direct users to the app's settings
    private func openiPhoneSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    MapView()
}
