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
        .onAppear {
            viewModel.checkLocationAuthorization()
        }
        .sheet(isPresented: $showPulseUI) {
            NavigationView {
                ConsoleView()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Serviços de localização desabilitados"),
                message: Text("Para uma melhor experiência é necessário permitir que o Postos Elétricos tenha acesso a sua localização nos ajustes do iPhone."),
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
            findInAreaButton
            map
        }
        .background(.regularMaterial)
        .navigationBarTitleDisplayMode(.automatic)
        .navigationTitle("Postos Elétricos")
        .searchable(text: $viewModel.searchText)
        .searchSuggestions {
            SuggestionsListView(viewModel: viewModel)
        }
    }

    private var map: some View {
        Map(position: $viewModel.position, selection: $viewModel.selectedID) {
            UserAnnotation()

            ForEach(viewModel.places, id: \.id) { place in
                if let coordinate = place.coordinate {
                    Marker(coordinate: coordinate) {
                        Label(place.name, systemImage: place.opened ? "bolt.fill" : "bolt.slash.fill")
                    }
                    .tag(place.id)
                    .tint(place.opened ? .accent : .gray.opacity(0.6))
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
                showsTraffic: viewModel.isRoutePresenting
            )
        )
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.onMapCameraChange(context)
        }
        .onChange(of: viewModel.selectedID) { _, newSelectedID in
            viewModel.updateSelectedPlace(withID: newSelectedID)
        }
        .sheet(
            isPresented: $viewModel.showBottomSheet,
            onDismiss: {
                viewModel.onDismissBottomSheet()
            },
            content: {
                if let selectedPlace = viewModel.selectedPlace {
                    BottomSheetMapView(
                        place: selectedPlace,
                        isRoutePresenting: viewModel.isRoutePresenting,
                        travelTime: viewModel.travelTime,
                        action: { type in
                            switch type {
                            case .close: viewModel.onBottomSheetCloseButtonTap()
                            case .route: viewModel.onShowRouteTap()
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .presentationCornerRadius(20)
                    .presentationDetents([.fraction(0.15), .fraction(0.3), .medium, .large], selection: $viewModel.presentationDetentionSelection)
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.regularMaterial.shadow(.drop(radius: 4)))
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                }
            }
        )
        .confirmationDialog("Abrir com", isPresented: $viewModel.showRouteOptions, titleVisibility: .visible) {
            if let coordinate = viewModel.selectedPlace?.coordinate {
                Button(MapApp.apple.title) { 
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.apple.open(coordinate: coordinate)
                    viewModel.onDismissRouteOptions()
                }
                Button(MapApp.googleMaps.title) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.googleMaps.open(coordinate: coordinate)
                    viewModel.onDismissRouteOptions()
                }
                Button(MapApp.waze.title) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.waze.open(coordinate: coordinate)
                    viewModel.onDismissRouteOptions()
                }
                Button(MapApp.uber.title) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    MapApp.uber.open(coordinate: coordinate, address: viewModel.selectedPlace?.vicinity ?? "")
                    viewModel.onDismissRouteOptions()
                }
                Button("Apenas visualizar") {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    viewModel.getDirections(to: coordinate)
                    viewModel.onDismissRouteOptions()
                }
                Button("Cancelar", role: .cancel) {
                    viewModel.onDismissRouteOptions()
                }
            }
        }
        .zIndex(0)
    }

    private var findInAreaButton: some View {
        FindInAreaButton(onTap: {
            withAnimation {
                viewModel.showFindInAreaButton = false
            }
            
            guard let center = viewModel.lastRegion?.center else { return }

            viewModel.fetchStationsFromGooglePlaces(in: center) { items in
                guard let items else { return }
                viewModel.getMapItemsRegion(places: items) { region in
                    viewModel.updateCameraPosition(forRegion: region)
                }
            }
        })
        .opacity(viewModel.shouldShowFindInAreaButton ? 1 : 0)
        .padding(6)
        .zIndex(1)
    }
}

#Preview {
    MapView()
}
