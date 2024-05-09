//
//  MapView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import MapKit
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
        .background(Color(colorScheme == .light ? .white : .darknessGray))
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

            ForEach(viewModel.places, id: \.id) { place in
                if let coordinate = place.coordinate {
                    Marker(coordinate: coordinate) {
                        Label(place.name, systemImage: "bolt.fill")
                    }
                    .tag(place.id)
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
        }
        .onChange(of: viewModel.selectedPlaceID) { _ , _ in
            viewModel.onDidSelectPlace()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.onMapCameraChange(context)
        }
        .overlay(alignment: .bottom) {
            if let selectedPlace = viewModel.selectedPlace {
                BottomMapDetailsView(
                    place: selectedPlace,
                    isRoutePresenting: viewModel.isRoutePresenting,
                    action: { type in
                        switch type {
                        case .close: viewModel.onDidClosePlaceDetails()
                        case .route: viewModel.handleRouteUpdates()
                        }
                    }
                )
            }
        }
        .confirmationDialog("Abrir com", isPresented: $viewModel.showMapApps) {
            if let coordinate = viewModel.selectedPlaceCoordinate {
                Button(MapApp.apple.title) { 
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.apple.open(coordinate: coordinate)
                }
                Button(MapApp.googleMaps.title) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.googleMaps.open(coordinate: coordinate)
                }
                Button(MapApp.uber.title) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.uber.open(coordinate: coordinate, address: viewModel.selectedPlace?.vicinity ?? "")
                }
                Button(MapApp.waze.title) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.waze.open(coordinate: coordinate)
                }
                Button("Apenas visualizar caminho") { 
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    viewModel.getDirections(to: coordinate)
                }
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
