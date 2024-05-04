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

    @StateObject var viewModel = MapViewModel()
    @State private var showPulseUI: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            content
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
        .sheet(isPresented: $showPulseUI) {
            NavigationView {
                ConsoleView()
            }
        }
        .onShakeGesture {
            withAnimation {
                showPulseUI.toggle()
            }

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        .toast(
            isShowing: $viewModel.showToast,
            message: viewModel.toastMessage
        )
    }

    private var content: some View {
        ZStack(alignment: .top) {
//            findInAreaButton

            VStack(spacing: .zero) {
                map
            }
        }
        .background(Color(colorScheme == .light ? .white : .darkGray))
        .navigationBarTitleDisplayMode(.automatic)
        .navigationTitle("Postos Elétricos")
        .searchable(text: $viewModel.searchText)
        .searchSuggestions {
            SuggestionsListView(viewModel: viewModel)
        }
    }


    private var map: some View {
        Map(
            position: $viewModel.position,
            selection: $viewModel.selectedPlaceID
        ) {
            UserAnnotation()

            ForEach(viewModel.places, id: \.id) { item in

                if let lat = item.geometry?.location?.lat,
                   let lng = item.geometry?.location?.lng {

                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

                    Marker(coordinate: coordinate) {
                        Label(
                            item.name ?? "Postos Elétricos",
                            systemImage: "bolt.fill"
                        )
                    }
                    .tag(item.id)
                    .tint(.green)
                    .annotationTitles(.hidden)
                }
            }

            if let route = viewModel.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 8)
            }
        }
        .mapStyle(
            .standard(
                elevation: .automatic,
                emphasis: .muted,
                pointsOfInterest: .all,
                showsTraffic: false
            )
        )
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
        .onChange(of: viewModel.selectedPlaceID) { _ , newSelectedItem in
            viewModel.onChangeOf(newSelectedItem)
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.onMapCameraChange(context)
        }
        .overlay(alignment: .bottom) {
            if let selectedPlace = viewModel.selectedPlace,
               let lat = selectedPlace.geometry?.location?.lat,
               let lng = selectedPlace.geometry?.location?.lng {

                BottomMapDetailsView(
                    place: selectedPlace,
                    isRoutePresenting: viewModel.isRoutePresenting,
                    action: {
                        if viewModel.isRoutePresenting {
                            viewModel.route = nil
                        } else {
                            guard let origin = viewModel.locationService.location else { return }
                            let destination = CLLocation(latitude: lat, longitude: lng)
                            viewModel.fetchRouteFrom(origin, to: destination)
                        }
                    }
                )
            }
        }
        .zIndex(0)
    }

    private var findInAreaButton: some View {
        FindInAreaButton(onTap: {
            withAnimation {
                viewModel.showFindInAreaButton = false
                viewModel.isSearchBarVisible = false
            }
            guard let center = viewModel.position.region?.center else { return }

            viewModel.fetchStationsFromGooglePlaces(in: center) { items in
                guard let items else { return }
                viewModel.getMapItemsRegion(places: items) { region in
                    viewModel.updateCameraPosition(forRegion: region)
                }
            }
        })
        .offset(y: viewModel.isSearchBarVisible ? 130 : 80)
        .opacity(viewModel.shouldShowFindInAreaButton ? 0.9 : 0)
        .zIndex(1)
    }
}

#Preview {
    MapView()
}
