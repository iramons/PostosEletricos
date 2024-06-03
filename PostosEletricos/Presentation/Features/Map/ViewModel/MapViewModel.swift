//
//  MapViewModel.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import MapKit
import SwiftUI
import Moya
import Combine
import AppTrackingTransparency

@MainActor
class MapViewModel: ObservableObject {

    @ObservedObject var locationManager = LocationManager.shared
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var state: ViewState = .none
    @Published var showBottomSheet: Bool = false
    @Published var selectedID: String?
    @Published var selectedPlace: Place?
    @Published var travelTime: String?
    @Published var showToast: Bool = false
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFirstLoading: Bool = true
    @Published var distance: CLLocationDistance = CLLocationDistance(4000)
    @Published var lastRegion: MKCoordinateRegion?
    @Published var lastContext: MapCameraUpdateContext?
    @Published var currentMapRect: MKMapRect?
    @Published var presentationDetentionSelection: PresentationDetent = .fraction(0.18)
    @Published var showRouteOptions: Bool = false
    @Published var showFindInAreaButton: Bool = false
    @Published var placesInFindedArea: [Place]?
    @Published var placesFromSearch: [Place] = []
    @Published var shouldShowBannerAds: Bool = false
    @Published var showRequestLocationAuthorization: Bool = false
    @Published private var adCoordinator = AdCoordinator()

    @Published var searchText: String = "" {
        didSet { findAutocomplete() }
    }

    @Published var places: [Place] = [] {
        didSet { updateSelectedPlaceWhenPlacesUpdate() }
    }

    var shouldShowPlacesFromSearch: Bool { !placesFromSearch.isEmpty }
    var shouldShowFindInAreaButton: Bool { !shouldShowPlacesFromSearch && showFindInAreaButton }
    var toastMessage: String = "Nenhum posto de recarga elétrica encontrado nesta área."
    var userCoordinate: CLLocationCoordinate2D?
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertButtonTitle: String = ""
    private var provider = MoyaProvider<GooglePlacesAPI>(plugins: [NetworkConfig.networkLogger])
    private var cancellables = Set<AnyCancellable>()
    private var shouldFetchStations: Bool = true
    
    // MARK: Lifecycle

    init() {
        observeUserLocation()
        checkIfLocationIsDenied()
    }

    private func observeUserLocation() {
        locationManager.$userLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self else { return }

                userCoordinate = location?.coordinate

                if let userCoordinate, shouldFetchStations {
                    shouldFetchStations.toggle()
                    performFetchData(in: userCoordinate)
                }
            }
            .store(in: &cancellables)

        locationManager.$shouldRequestAuthorization
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                guard let self else { return }
                showRequestLocationAuthorization = bool
            }
            .store(in: &cancellables)

        adCoordinator.$onDismissAd
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dismissed in
                guard let self else { return }

                if dismissed {
                    showRouteOptions.toggle()
                }
            }
            .store(in: &cancellables)

        adCoordinator.$failedToLoadAd
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dismissed in
                guard let self else { return }

                if dismissed {
                    showRouteOptions.toggle()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Selected Place

    func updateSelectedPlace(withID id: String?) {
        selectedPlace = places.first(where: { $0.id == id })
        presentationDetentionSelection = .fraction(0.18)
        handleSelectedPlaceUpdated()
        adCoordinator.loadAd()
        getDirections(to: selectedPlace?.coordinate)
    }

    func handleSelectedPlaceUpdated() {
        withAnimation { showBottomSheet = selectedPlace != nil }


        guard let selectedPlace else { return }

        /// update camera
        guard let selectedPlaceCoordinate = selectedPlace.coordinate else { return }
        let mapItem = MKMapItem(placemark: .init(coordinate: selectedPlaceCoordinate))
        updateCameraPosition(with: .item(mapItem))

        /// update place
        guard let placeID = selectedPlace.placeID else { return }
        fetchPlace(placeID: placeID) { placeFromGoogle in
            if let placeFromGoogle, let existingPlaceIndex = self.places.firstIndex(where: { $0.placeID == placeFromGoogle.placeID }) {
                withAnimation {
                    self.places[existingPlaceIndex].update(placeFromGoogle)
                }
            }
        }
    }

    func onDismissBottomSheet() {
        guard selectedID != nil, !showRouteOptions else { return }

        deselectPlace()

        if let lastRegion {
            updateCameraPosition(forRegion: lastRegion)
        }
    }

    func onBottomSheetCloseButtonTap() {
        guard selectedID != nil else { return }

        deselectPlace()

        if let lastRegion {
            updateCameraPosition(forRegion: lastRegion)
        }
    }

    private func deselectPlace() {
        withAnimation {
            self.selectedID = nil

            if showBottomSheet {
                showBottomSheet = false
            }
        }
    }

    func onDismissSearch() {
        deselectPlace()
    }

    // MARK: - Route

    func getDirections(to destination: CLLocationCoordinate2D?) {
        guard let userCoordinate else { return }
        guard let destination else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        _Concurrency.Task {
            let result = try? await MKDirections(request: request).calculate()
            guard let route = result?.routes.first else { return }
            getTravelTime(forRoute: route)
        }
    }

    func onDismissRouteOptions() {
        withAnimation { showBottomSheet = true }
    }

    /// Function to update camera position to fit all markers
    func getMapItemsRegion(
        places: [Place],
        includingUserLocation: Bool = false,
        completion: @escaping (MKCoordinateRegion) -> Void
    ) {
        guard !places.isEmpty else { return }

        // Calculate the bounding region for all markers
        var minLat = places[0].coordinate?.latitude ?? 0
        var maxLat = places[0].coordinate?.latitude ?? 0
        var minLon = places[0].coordinate?.longitude ?? 0
        var maxLon = places[0].coordinate?.longitude ?? 0

        for item in places {
            minLat = min(minLat, item.coordinate?.latitude ?? 0)
            maxLat = max(maxLat, item.coordinate?.latitude ?? 0)
            minLon = min(minLon, item.coordinate?.longitude ?? 0)
            maxLon = max(maxLon, item.coordinate?.longitude ?? 0)
        }

        // Create a region that contains all markers
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.2, longitudeDelta: (maxLon - minLon) * 1.2)
        let newRegion = MKCoordinateRegion(center: center, span: span)

        self.lastRegion = newRegion

        completion(newRegion)
    }

    func onMapCameraChange(_ context: MapCameraUpdateContext) {
        if position.positionedByUser {
            withAnimation {
                lastRegion = context.region

                if !showFindInAreaButton {
                    showFindInAreaButton.toggle()
                }
            }
        }

        update(context.rect)
        update(context.camera.distance)
        saveLast(context)
    }

    func onShowRouteTap() {
        showAd()
    }

    private func showAd() {
        adCoordinator.presentAd()
    }

    func checkLocationAuthorization() {
        locationManager.handleAuthorizationStatus()
    }

    func requestAppTrackingAuthorizationIfNeeded() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            DispatchQueue.main.async {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    withAnimation { self.shouldShowBannerAds = (status == .authorized) }
                })
            }
        }
    }

    // MARK: Private methods

    private func performFetchData(in coordinate: CLLocationCoordinate2D?) {
        guard let coordinate else { return }

        fetchStationsFromGooglePlaces(in: coordinate, radius: CLLocationDistance(4000)) { [weak self] places in
            guard let self, let places else { return }

            getMapItemsRegion(places: places) { region in
//                self.updateCameraPosition(forRegion: region)
                if let userCoordinate = self.userCoordinate {

                    // Find the farthest place
                    if let farthestPlaceCoordinate = farthestPlaceCoordinate(from: userCoordinate, places: places) {
                        let distance = distanceBetween(userCoordinate, farthestPlaceCoordinate)
                        let distanceInMeters: Double = distance
                        self.updateCameraDistance(distanceInMeters)
                    } else {
                        print("No places provided.")
                    }
                }
                //                    _Concurrency.Task {
                //                        await self.fetchStationsFromMapKit() { itemsFromMapKit in
                //                            guard let itemsFromMapKit else { return }
                //
                //                            self.getMapItemsRegion(items: itemsFromMapKit) { region in
                //                                self.updateCameraPosition(forRegion: region)
                //                            }
                //                        }
                //                    }
            }
        }
    }

    private func getTravelTime(forRoute route: MKRoute) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }

    private func setShowToast(_ bool: Bool) {
        withAnimation { showToast = bool }
    }

    private func append(_ place: Place) {
        if let existingPlaceIndex = places.firstIndex(where: { $0.placeID == place.placeID }) {
            places[existingPlaceIndex].update(place)
        } else {
            places.append(place)
        }

    }

    private func appendPlacesInFindedArea(for place: Place) {
        if let existingPlaceIndex = placesInFindedArea?.firstIndex(where: { $0.placeID == place.placeID }) {
            placesInFindedArea?[existingPlaceIndex].update(place)
        } else {
            placesInFindedArea?.append(place)
        }
    }

    private func updateSelectedPlaceWhenPlacesUpdate() {
        if let selectedPlace {
            self.selectedPlace = places.first(where: { $0.placeID == selectedPlace.placeID })
        }
    }

    private func checkIfLocationIsDenied() {
        if locationManager.isDenied {
            setAlert(
                title: "Serviços de localização desabilitados",
                message: "Para uma melhor experiência é necessário permitir que o \(Bundle.main.appName) tenha acesso a sua localização nos ajustes do iPhone.",
                actionButtonTitle: "ir para Ajustes"
            )
        }
    }

    private func setAlert(title: String, message: String, actionButtonTitle: String) {
        alertTitle = title
        alertMessage = message
        alertButtonTitle = actionButtonTitle
        withAnimation { showAlert = true }
    }

    private func update(_ rect: MKMapRect) {
        currentMapRect = rect
    }

    private func update(_ distance: Double) {
        self.distance = distance / 3.8
    }

    private func saveLast(_ context: MapCameraUpdateContext) {
        lastContext = context
    }
}

// MARK: - GooglePlaces

extension MapViewModel {

    // MARK: fetchStations from google

    func fetchStationsFromGooglePlaces(
        in location: CLLocationCoordinate2D,
        radius: CLLocationDistance? = nil,
        completion: @escaping ([Place]?) -> Void
    ) {
        isLoading = true

        let expectedRadius = radius ?? distance

        provider.request(.places(location: location, radius: expectedRadius)) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case let .success(response):
                strongSelf.placesInFindedArea = []

                do {
                    let response = try response.map(GooglePlacesResponse.self, failsOnEmptyData: true)

                    guard let places = response.results, !places.isEmpty else {
                        printLog(.warning, "No results found in this area.")
                        strongSelf.setShowToast(true)
                        completion(nil)
                        return
                    }


                    places.forEach { place in
                        self?.append(place)
                        self?.appendPlacesInFindedArea(for: place)
                    }

                    completion(places)
                }
                catch {
                    printLog(.error, "\(error)")
                    completion(nil)
                }

                strongSelf.isLoading = false

            case let .failure(error):
                printLog(.error, "failure request: \(error)")
                strongSelf.isLoading = false
                completion(nil)
            }

            strongSelf.isFirstLoading = false
        }
    }

    // MARK: getPlace from google

    func fetchPlace(placeID: String, completion: @escaping (Place?) -> Void) {
        provider.request(.place(placeID: placeID)) { result in
            switch result {
            case let .success(response):
                do {
                    let response = try response.map(GooglePlaceResponse.self, failsOnEmptyData: true)

                    guard let place = response.result else {
                        completion(nil)
                        return
                    }

                    completion(place)
                } catch {
                    printLog(.error, String(describing: error))
                    completion(nil)
                }

            case let .failure(error):
                printLog(.error, String(describing: error))
                completion(nil)
            }
        }
    }

    // MARK: AutoComplete

    func findAutocomplete() {
        provider.request(.autocomplete(query: searchText, location: userCoordinate)) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                do {
                    let response = try response.map(GooglePlacesAutocompleteResponse.self, failsOnEmptyData: true)

                    guard let predictions = response.predictions else { return }

                    let places: [Place] = predictions.map { prediction in
                        Place(placeID: prediction.placeID, name: prediction.description ?? "")
                    }

                    let sortedPlaces = places.sorted {
                        levenshteinDistance(from: $0.name.lowercased(), to: self.searchText.lowercased()) <
                            levenshteinDistance(from: $1.name.lowercased(), to: self.searchText.lowercased())
                    }

                    self.placesFromSearch = sortedPlaces

                } catch {
                    printLog(.error, String(describing: error))
                    return
                }

            case let .failure(error):
                printLog(.error, String(describing: error))
                return
            }
        }
    }

    // MARK: - MapKit

#warning("temporally commented, will back this feature soon.")
    func fetchStationsFromMapKit(completion: @escaping ([MKMapItem]?) -> Void) async {
        //        guard let region = position.region else { return }
        //        let request = MKLocalSearch.Request()
        //        request.region = region
        //        request.naturalLanguageQuery = "eletric charge"
        //        let results = try? await MKLocalSearch(request: request).start()
        //
        //        printLog(.error, "results = \(String(describing: results))")
        //
        //        results?.mapItems.forEach { item in
        //            withAnimation {
        //                places.append(item)
        //                placesInFindedArea?.append(item)
        //            }
        //        }
        //        completion(itemsInFindedArea)
    }
}

// MARK: - Update Camera Position

@MainActor
extension MapViewModel {
    func updateCameraPosition(with position: MapCameraPosition) {
        withAnimation { self.position = position }
    }

    func updateCameraPosition(forCoordinate coordinate: CLLocationCoordinate2D, withSpan: MKCoordinateSpan? = nil) {
        if let withSpan {
            withAnimation { position = .region(.init(center: coordinate, span: withSpan)) }
        } else {
            guard let span = position.region?.span else { return }
            withAnimation { position = .region(.init(center: coordinate, span: span)) }
        }
    }

    func updateCameraPosition(forRegion region: MKCoordinateRegion) {
        withAnimation { position = .region(.init(center: region.center, span: region.span)) }
    }

    func updateCameraDistance(_ distance: Double) {
        guard let centerCoordinate = lastContext?.camera.centerCoordinate else { return }
        withAnimation { position = .camera(.init(centerCoordinate: centerCoordinate, distance: distance * 4)) }
    }

    func updateCameraPositionForRoute() {
        guard let userCoordinate else { return }
        guard let selectedPlaceCoordinate = selectedPlace?.coordinate else { return }

        /// Calculate min and max coordinates
        let minLatitude = min(userCoordinate.latitude, selectedPlaceCoordinate.latitude)
        let maxLatitude = max(userCoordinate.latitude, selectedPlaceCoordinate.latitude)
        let minLongitude = min(userCoordinate.longitude, selectedPlaceCoordinate.longitude)
        let maxLongitude = max(userCoordinate.longitude, selectedPlaceCoordinate.longitude)

        /// Calculate center
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        /// Calculate span
        let padding: CGFloat = 2.2
        let spanLatitude = (maxLatitude - minLatitude) * padding
        let spanLongitude = (maxLongitude - minLongitude) * padding
        let span = MKCoordinateSpan(latitudeDelta: spanLatitude, longitudeDelta: spanLongitude)

        updateCameraPosition(forRegion: MKCoordinateRegion(center: center, span: span))
    }

    func updateCameraPositionForTwoRegions(_ regionA: MKCoordinateRegion, _ regionB: MKCoordinateRegion) {
        /// Calculate min and max coordinates
        let minLatitude = min(regionA.center.latitude, regionB.center.latitude)
        let maxLatitude = max(regionA.center.latitude, regionB.center.latitude)
        let minLongitude = min(regionA.center.longitude, regionB.center.longitude)
        let maxLongitude = max(regionA.center.longitude, regionB.center.longitude)

        /// Calculate center
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        /// Calculate span
        let padding: CGFloat = 3
        let spanLatitude = (maxLatitude - minLatitude) * padding
        let spanLongitude = (maxLongitude - minLongitude) * padding
        let span = MKCoordinateSpan(latitudeDelta: spanLatitude, longitudeDelta: spanLongitude)

        updateCameraPosition(forRegion: MKCoordinateRegion(center: center, span: span))
    }
}

func distanceBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationDistance {
    let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
    let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
    return location1.distance(from: location2)
}

func farthestPlaceCoordinate(from userLocation: CLLocationCoordinate2D, places: [Place]) -> CLLocationCoordinate2D? {
    let coordinates = places.map({ $0.coordinate })

    guard let farthestPlace = coordinates.max(by: {
        if let coordA = $0, let coordB = $1 {
            return distanceBetween(userLocation, coordA) < distanceBetween(userLocation, coordB)
        } else {
            return false
        }
    }) else {
        return nil
    }
    return farthestPlace
}
