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
                            item.name,
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
            if let selectedPlace = viewModel.selectedPlace {
                BottomMapDetailsView(
                    place: selectedPlace,
                    isRoutePresenting: viewModel.isRoutePresenting,
                    action: { type in

                        switch type {
                        case .close:
                            viewModel.deselectPlace()
                        case .route:
                            viewModel.handleRouteUpdates()
                        }
                    }
                )
            }
        }
        .confirmationDialog(
            "Abrir com",
            isPresented: $viewModel.showMapApps,
            titleVisibility: .visible
        ) {
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

enum MapApp: CaseIterable {
    case apple, googleMaps, uber, waze

    var title: String {
        switch self {
        case .apple: return "Apple Maps"
        case .googleMaps: return "Google Maps"
        case .uber: return "Uber"
        case .waze: return "Waze"
        }
    }

    var scheme: String {
        switch self {
        case .apple: return "http"
        case .googleMaps: return "comgooglemaps"
        case .uber: return "uber"
        case .waze: return "waze"
        }
    }

    var isInstalled: Bool {
        guard let url = URL(string: self.scheme.appending("://")) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    func url(for coordinate: CLLocationCoordinate2D?, address: String = "") -> URL? {
        guard let coordinate else { return nil }

        let latitude = coordinate.latitude
        let longitude = coordinate.longitude

        var urlString: String = ""

        switch self {
        case .apple:
            urlString = "\(scheme)://maps.apple.com/?daddr=\(latitude),\(longitude)"

        case .googleMaps:
            urlString = "\(scheme)://?daddr=\(latitude),\(longitude)&directionsmode=driving"

        case .uber:
            urlString = "\(scheme)://?action=setPickup&dropoff[latitude]=\(latitude)&dropoff[longitude]=\(longitude)&dropoff[formatted_address]=\(address)"

        case .waze:
            urlString = "\(scheme)://?ll=\(latitude),\(longitude)navigate=yes"
        }

        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString

        return URL(string: urlwithPercentEscapes)
    }

    func open(coordinate: CLLocationCoordinate2D, address: String = "") {
        guard let url = url(for: coordinate, address: address) else { return }
        url.openURL()
    }
}

extension View {
    func opensMap(at location: CLLocationCoordinate2D?) -> some View {
        return self.modifier(OpenMapViewModifier(location: location))
    }
}

struct OpenMapViewModifier: ViewModifier {

    var location: CLLocationCoordinate2D?

    @State private var showingAlert: Bool = false
    private let installedApps = MapApp.allCases.filter { $0.isInstalled }

    func body(content: Content) -> some View {
        Button(action: {
            if installedApps.count > 1 {
                showingAlert = true
            } else if let app = installedApps.first, let url = app.url(for: location) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) {
            content.confirmationDialog("Abrir com", isPresented: $showingAlert) {

                let appButtons: [ActionSheet.Button] = self.installedApps.compactMap { app in
                    guard let url = app.url(for: self.location) else { return nil }
                    return .default(Text(app.title)) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
//                return ActionSheet(title: Text("Navigate"), message: Text("Select an app..."), buttons: appButtons + [.cancel()])
            }
        }
    }
}
