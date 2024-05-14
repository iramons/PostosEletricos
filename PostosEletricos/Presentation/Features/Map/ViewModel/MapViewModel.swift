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

@MainActor
class MapViewModel: ObservableObject {
    
    // MARK: Lifecycle
    
    init() {
        DispatchQueue.main.async {
            self.showLocationServicesAlert = self.locationService.showLocationServicesAlert
        }

        bind()
    }

    // TODO: check to user .automatic in future

    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)

    @Published var state: ViewState = .none

    // MARK: Places

    @Published var places: [Place] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.selectedPlace != nil {
                    self.selectedPlace = self.places.first(where: { $0.placeID == self.selectedPlace?.placeID })
                }
            }
        }
    }

    // MARK: - Selected Place

    @Published var showBottomSheet: Bool = false

    @Published var selectedID: String? {
        didSet { printLog(.notice, "selectedID is \(String(describing: selectedID))") }
    }

    @Published var selectedPlace: Place? {
        didSet { printLog(.notice, "selectedPlace is \(String(describing: selectedPlace))") }
    }

    func updateSelectedPlace(withID id: String?) {
        selectedPlace = places.first(where: { $0.id == id })
        printLog(.notice, "updatedSelectedPlace is: \(selectedPlace)")

        handleSelectedPlaceUpdated()
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
            if let placeFromGoogle {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if let existingPlaceIndex = places.firstIndex(where: { $0.placeID == placeFromGoogle.placeID }) {
                        withAnimation {
                            self.places[existingPlaceIndex].update(placeFromGoogle)
                        }
                    }
                }
            }
        }
    }

    func onDismissBottomSheet() {
        guard selectedID != nil, !showRouteOptions else { return }

        deselectPlace()

        if let lastRegion { updateCameraPosition(forRegion: lastRegion) }
    }
    
    func onBottomSheetCloseButtonTap() {
        guard selectedID != nil else { return }
        
        deselectPlace()

        if let lastRegion { updateCameraPosition(forRegion: lastRegion) }
    }

    private func deselectPlace() {
        withAnimation {
            self.selectedID = nil

            if showBottomSheet {
                showBottomSheet = false
            }
        }
    }

    // MARK: - Find in Area

    @Published var showFindInAreaButton: Bool = false

    var shouldShowFindInAreaButton: Bool {
        return !shouldShowPlacesFromSearch && showFindInAreaButton
    }
    @Published var placesInFindedArea: [Place]?

    var toastMessage: String = "Nenhum posto de recarga elétrica encontrado nesta área."

    // MARK: - Search

    @Published var searchText: String = "" {
        didSet { findAutocomplete() }
    }

    @Published var placesFromSearch: [Place] = []

    var shouldShowPlacesFromSearch: Bool {
        return !placesFromSearch.isEmpty
    }

    func onDismissSearch() {
        deselectPlace()
    }

    // MARK: - Route

    @Published var route: MKRoute? {
        didSet {
            let hasRoute = route != nil

            withAnimation {
                presentationDetentionSelection = hasRoute ? .fraction(0.15) : .fraction(0.3)
            }

            if hasRoute {
                updateCameraPositionForRoute()
            }
        }
    }

    var isRoutePresenting: Bool {
        route != nil
    }

    func getDirections(to destination: CLLocationCoordinate2D?) {
        guard let userCoordinate else { return }
        guard let destination else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        _Concurrency.Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            getTravelTime()
        }
    }

    func onDismissRouteOptions() {
        withAnimation { showBottomSheet = true }
    }

    // MARK: Others

    @Published var travelTime: String?
    @Published var showToast: Bool = false
    @Published var showLocationServicesAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFirstLoading: Bool = true
    @Published var distance: CLLocationDistance = CLLocationDistance(3000)
    @Published var lastRegion: MKCoordinateRegion?
    @Published var lastContext: MapCameraUpdateContext?
    @Published var presentationDetentionSelection: PresentationDetent = .fraction(0.3)



    func updateDistance(with context: MapCameraUpdateContext) {
        distance = context.camera.distance / 3.8
    }

    func saveLast(_ context: MapCameraUpdateContext) {
        lastContext = context
    }

    /// Function to update camera position to fit all markers
    func getMapItemsRegion(places: [Place], completion: @escaping (MKCoordinateRegion) -> Void) {
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
        
        updateDistance(with: context)
        saveLast(context)
    }

    func onShowRouteTap() {
        if isRoutePresenting {
            route = nil
        } else {
            showRouteOptions.toggle()
        }
    }

    @Published var showRouteOptions: Bool = false

    // MARK: Private

    private enum Constants {
        static let defaultRadius: Float = 3000
        static let defaultCoordinate: CLLocationCoordinate2D = .init(latitude: -22.904232, longitude: -43.104371)
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    
    @Injected private var locationService: LocationService

    var userCoordinate: CLLocationCoordinate2D?

    private var provider = MoyaProvider<GooglePlacesAPI>(plugins: [NetworkConfig.networkLogger])
    
    private var cancellables = Set<AnyCancellable>()

    /// indicates when need fetch data from API, when it's false should stop fetching.
    private var shouldFetchStations: Bool = true

    private func bind() {
        locationService.$location
            .receive(on: DispatchQueue.main)
            .sink { location in
                self.userCoordinate = location?.coordinate

                if self.shouldFetchStations {
                    self.shouldFetchStations.toggle()

                    self.performFetchData(in: location?.coordinate)
                }
            }
            .store(in: &cancellables)
    }

    private func performFetchData(in coordinate: CLLocationCoordinate2D?) {
        guard let coordinate else { return }

        fetchStationsFromGooglePlaces(in: coordinate, radius: CLLocationDistance(3000)) { [weak self] places in
            guard let self, let places else { return }

            getMapItemsRegion(places: places) { region in
                self.updateCameraPosition(forRegion: region)

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
    
    private func getTravelTime() {
        guard let route else { return }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }

    private func setShowToast(_ bool: Bool) {
        withAnimation {
            showToast = bool
        }
    }
}

// MARK: - Commom

extension MapViewModel {

    // MARK: fetchStations from google

    func fetchStationsFromGooglePlaces(
        in location: CLLocationCoordinate2D,
        radius: CLLocationDistance? = nil,
        completion: @escaping ([Place]?) -> Void
    ) {
        isLoading = true

        let expectedRadius = radius ?? distance

        provider.request(.places(location: location, radius: expectedRadius), callbackQueue: .main) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case let .success(response):
                strongSelf.placesInFindedArea = []

                do {
                    let response = try response.map(GooglePlacesResponse.self, failsOnEmptyData: true)

                    guard let places = response.results else {
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
        provider.request(.place(placeID: placeID), callbackQueue: .main) { result in
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

    private func append(_ place: Place) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if let existingPlaceIndex = places.firstIndex(where: { $0.placeID == place.placeID }) {
                places[existingPlaceIndex].update(place)
            } else {
                places.append(place)
            }
        }
    }

    private func appendPlacesInFindedArea(for place: Place) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if let existingPlaceIndex = placesInFindedArea?.firstIndex(where: { $0.placeID == place.placeID }) {
                placesInFindedArea?[existingPlaceIndex].update(place)
            } else {
                placesInFindedArea?.append(place)
            }
        }
    }

    // MARK: MapKit

    func fetchStationsFromMapKit(completion: @escaping ([MKMapItem]?) -> Void) async {
        guard let region = position.region else { return }
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = "eletric charge"
        let results = try? await MKLocalSearch(request: request).start()

        printLog(.error, "results = \(String(describing: results))")

        results?.mapItems.forEach { item in
            withAnimation {
//                places.append(item)
//                placesInFindedArea?.append(item)
            }
        }
//        completion(itemsInFindedArea)
    }

    // MARK: AutoComplete

    func findAutocomplete() {
        provider.request(.autocomplete(query: searchText, location: userCoordinate), callbackQueue: .main) { [weak self] result in
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

                    DispatchQueue.main.async {
                        self.placesFromSearch = sortedPlaces
                    }
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
}

// MARK: Update Camera Position

extension MapViewModel {
    func updateCameraPosition(with position: MapCameraPosition) {
        withAnimation { self.position = position }
    }

    func updateCameraPosition(forCoordinate coordinate: CLLocationCoordinate2D) {
        guard let span = position.region?.span else { return }
        withAnimation { position = .region(.init(center: coordinate, span: span)) }
    }

    func updateCameraPosition(forRegion region: MKCoordinateRegion) {
        withAnimation { position = .region(.init(center: region.center, span: region.span)) }
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
}
