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

    var body: some View {
        VStack {
            MapHeaderView()
                        
            Map(
                position: $viewModel.cameraPosition,
                selection: $viewModel.selectedItem
            ) {
                UserAnnotation()
                
                ForEach(viewModel.items, id: \.self) { item in
                    Marker(coordinate: item.placemark.coordinate) {
                        Label(
                            item.name ?? "Postos Elétricos",
                            systemImage: "bolt.fill"
                        )
                    }
                    .tint(.green)
                    .tag(item.name?.description)
                    .annotationTitles(.hidden)
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
            .onChange(of: viewModel.selectedItem) { _ , newValue in
                guard let location = newValue?.placemark.location else { return }
                viewModel.updateCamera(to: location)
            }
            .onMapCameraChange(frequency: .continuous) { context in
                viewModel.updateCameraSpan(with: context)
            }
            .overlay(alignment: .bottom) {
                if let selection = viewModel.selectedItem {
                    BottomMapDetailsView(
                        selection: selection,
                        isRoutePresenting: viewModel.isRoutePresenting,
                        action: {
                            guard let origin = viewModel.location,
                                  let destionation = selection.placemark.location
                            else { return }
                            
                            if viewModel.isRoutePresenting {
                                viewModel.route = nil
                            } else {
                                viewModel.fetchRouteFrom(origin, to: destionation)
                            }
                        }
                    )
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
                    /// Direct users to the app's settings
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
