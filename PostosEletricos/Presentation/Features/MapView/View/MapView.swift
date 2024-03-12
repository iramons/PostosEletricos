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
    
    @State private var selection: MKMapItem?
    
    var body: some View {
        VStack {
            MapHeaderView()
            Map(position: $viewModel.cameraPosition) {
                UserAnnotation {
                    MapUserAnnotation()
                }
                
                ForEach(viewModel.items, id: \.self) { item in
                    Annotation("", coordinate: item.placemark.coordinate) {
                        PlaceAnnotationView()
                            .onTapGesture {
                                withAnimation {
                                    selection = item
                                }
                            }
                    }
                }
                
                if let route = viewModel.route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 8)
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading) {
                    if let selection {
                        Text("Endereço")
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(.top, 8)
                            .padding(.leading, 16)

                        Text(selection.placemark.name ?? "SEMNOME-1")
                            .multilineTextAlignment(.leading)
                            .fontWeight(.regular)
                            .foregroundStyle(.black)
                            .padding(.leading, 16)

                        Button(
                            action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.easeInOut) {
                                    guard let origin = viewModel.location,
                                          let destionation = selection.placemark.location
                                    else { return }
                                    
                                    if viewModel.isRoutePresenting {
                                        viewModel.route = nil
                                    } else {
                                        viewModel.fetchRouteFrom(origin, to: destionation)
                                    }
                                }
                            },
                            label: {
                                Text(viewModel.showRouteButtonTitle)
                                    .multilineTextAlignment(.center)
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 3)
                                    .background(viewModel.isRoutePresenting ? .red : .indigo)
                                    .cornerRadius(8)
                            }
                        )
                        .padding(.leading, 16)
                        
                        LocationPreviewLookAroundView(selectedResult: selection)
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                    }
                }
                .background(.white)
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
            }
            .onChange(of: selection) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                guard let selection else { return }
                guard let location = selection.placemark.location else { return }
                viewModel.updateCamera(to: location)
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

extension AnyTransition {
    static var moveUpward: AnyTransition {
        AnyTransition.move(edge: .bottom)
    }
}
