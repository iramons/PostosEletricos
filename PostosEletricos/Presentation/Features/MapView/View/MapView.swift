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
import OSLog

// MARK: MapView

struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()

    @Namespace var animation

    @State private var distanceScrolled: CLLocationDistance = 0

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea(edges: .all)

            if viewModel.showSplash {
                SplashView(viewModel: viewModel, animation: animation)
                    .zIndex(.infinity)
            }

            withAnimation(.easeIn(duration: 2)) {
                FindInAreaButton(isLoading: viewModel.isLoading) {
                    guard let cameraPositionCoordinate = viewModel.cameraPosition.region?.center else { return }

                    viewModel.fetchStations(in: cameraPositionCoordinate) { items in
                        guard let items else { return }
                        viewModel.updateCameraPositionToFitMarkers(items: items)
                    }
                }
                .offset(y: viewModel.showFindInAreaButton ? 80 : -UIScreen.main.bounds.height)
                .animation(.easeInOut(duration: 0.8), value: viewModel.showFindInAreaButton)
                .zIndex(1)
            }

            VStack(spacing: .zero) {
                MapHeaderView(animation: animation)
                    .zIndex(1)

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
                .mapStyle(
                    .standard(
                        elevation: .realistic,
                        emphasis: .automatic,
                        pointsOfInterest: .all,
                        showsTraffic: true
                    )
                )
                .mapControls {
                    MapCompass()
                    MapPitchToggle()
                    MapUserLocationButton()
                    MapScaleView()
                }
                .onChange(of: viewModel.selectedItem) { _ , newSelectedItem in
                    guard let coordinate = newSelectedItem?.placemark.coordinate else { return }
                    viewModel.updateCameraPosition(forCoordinate: coordinate)
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    viewModel.handleCamera(with: context)
                    viewModel.updateDistance(with: context)
                    viewModel.saveLast(context)
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
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
            .zIndex(0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    viewModel.showSplash = false
                }
            }
        }
    }
}

#Preview {
    MapView()
}
