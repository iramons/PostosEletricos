//
//  MapView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import MapKit
import AdSupport
import AppTrackingTransparency
import GoogleMobileAds
import UIKit

// MARK: MapView

struct MapView: View {

    @StateObject var viewModel = MapViewModel()
    private var interstitial: GADInterstitialAd?

    var body: some View {
        NavigationStack {
            content
        }
        .onAppear { viewModel.checkLocationAuthorization() }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                primaryButton: .default(Text(viewModel.alertButtonTitle)) {
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        url.openURL()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .fullScreenCover(isPresented: $viewModel.showRequestLocationAuthorization) {
            RequestLocationView()
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                VStack(alignment: .leading) {
                    Text(Bundle.main.appName)
                      .font(.custom("Roboto-Black", size: 34))
                      .multilineTextAlignment(.leading)
                      .foregroundColor(.primary)
                      .padding(.top, 96)

                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .searchSuggestions { SuggestionsListView(viewModel: viewModel) }
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
                    .tint(place.opened ? .accent : .lightnessGray)
                    .annotationTitles(.hidden)
                }
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
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.onMapCameraChange(context)
        }
        .onChange(of: viewModel.selectedID) { _, newSelectedID in
            viewModel.updateSelectedPlace(withID: newSelectedID)
        }
        .onChange(of: viewModel.showBottomSheet) {
            viewModel.requestAppTrackingAuthorizationIfNeeded()
        }
        .sheet(
            isPresented: $viewModel.showBottomSheet,
            onDismiss: { viewModel.onDismissBottomSheet() },
            content: {
                if let selectedPlace = viewModel.selectedPlace {
                    BottomSheetMapView(
                        place: selectedPlace,
                        travelTime: viewModel.travelTime,
                        showBannerAds: viewModel.shouldShowBannerAds,
                        action: { type in
                            switch type {
                            case .close: viewModel.onBottomSheetCloseButtonTap()
                            case .route: viewModel.onShowRouteTap()
                            }
                        })
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .presentationDetents([.fraction(0.18), .fraction(0.3), .fraction(0.8)], selection: $viewModel.presentationDetentionSelection)
                        .presentationBackgroundInteraction(.enabled)
                        .presentationCornerRadius(26)
                        .presentationDragIndicator(.automatic)
                        .presentationBackground(.regularMaterial.shadow(.drop(radius: 4)))
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
                Button("Cancelar", role: .cancel) {
                    viewModel.onDismissRouteOptions()
                }
            }
        }
        .zIndex(0)
    }

    private var findInAreaButton: some View {
        FindInAreaButton(action: {
            withAnimation { viewModel.showFindInAreaButton = false }

            guard let center = viewModel.lastRegion?.center else { return }

            viewModel.fetchStationsFromGooglePlaces(in: center) { places in
                guard let places else { return }
                viewModel.getMapItemsRegion(places: places) { region in
                    if let farthestPlaceCoordinate = farthestPlaceCoordinate(from: center, places: places) {
                        let distance = distanceBetween(center, farthestPlaceCoordinate)
                        let distanceInMeters: Double = distance + 2000
                        viewModel.updateCameraDistance(distanceInMeters)
                    } else {
                        print("No places provided.")
                    }
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
