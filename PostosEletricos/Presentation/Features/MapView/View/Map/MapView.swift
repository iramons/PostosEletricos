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
import Pulse
import PulseUI

// MARK: MapView

struct MapView: View {

    var animation: Namespace.ID

    @StateObject private var viewModel = MapViewModel()
    @State private var showPulseUI: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea(edges: .all)

            FindInAreaButton(onTap: {
                viewModel.showFindInAreaButton = false
                guard let center = viewModel.position.region?.center else { return }

                viewModel.fetchStationsFromGooglePlaces(in: center) { items in
                    guard let items else { return }
                    viewModel.getMapItemsRegion(items: items) { region in
                        viewModel.updateCameraPosition(forRegion: region)
                    }
                }
            })
            .offset(y: viewModel.showFindInAreaButton ? 80 : -UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 2), value: viewModel.showFindInAreaButton)
            .zIndex(1)

            VStack(spacing: 0) {
                MapHeaderView(
                    withAnimation: animation,
                    isLoading: viewModel.isLoading
                )
                .zIndex(2)

                Map(
                    position: $viewModel.position,
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
                    viewModel.onChangeOf(newSelectedItem)
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    viewModel.onMapCameraChange(context)
                }
                .onAppear {
                    viewModel.onAppear()
                }
                .overlay(alignment: .bottom) {
                    if let selection = viewModel.selectedItem {
                        BottomMapDetailsView(
                            selection: selection,
                            isRoutePresenting: viewModel.isRoutePresenting,
                            action: {
                                guard let origin = viewModel.locationService.location,
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
            .toast(
                isShowing: $viewModel.showToast,
                message: viewModel.toastMessage
            )
        }
        .onShakeGesture {
            UIImpactFeedbackGenerator(style: .soft)
                .impactOccurred()

            withAnimation {
                showPulseUI.toggle()
            }
        }
        .sheet(isPresented: $showPulseUI) {
            NavigationView {
                ConsoleView()
            }
        }
    }
}

#Preview {
    @Namespace var animation
    return MapView(animation: animation)
}