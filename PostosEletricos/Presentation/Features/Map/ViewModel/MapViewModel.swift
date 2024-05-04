//
//  MapViewModel.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Moya
import Combine
import GooglePlaces

@MainActor
class MapViewModel: ObservableObject {
    
    // MARK: Lifecycle
    
    init() {
        DispatchQueue.main.async {
            self.showLocationServicesAlert = self.locationService.showLocationServicesAlert
        }

        bind()
    }

    // MARK: Public

    @Published var position: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .region(
            .init(center:
                    .init(latitude: -22.0607781, longitude: -44.2432158),
                  latitudinalMeters: 3000,
                  longitudinalMeters: 3000
            )
        )
    )

    @Published var state: ViewState = .none

    // MARK: Places

    @Published var places: [Place] = []
    private var placesSet: Set<Place> = [] {
        willSet {
            DispatchQueue.main.async {
                self.places = self.placesSet.sorted()
            }
        }
    }

    @Published var selectedPlaceID: String?
    var selectedPlace: Place? { places.first(where: { $0.id == selectedPlaceID }) }

    @Published var placesInFindedArea: [Place]?
    private var placesInFindedAreaSet: Set<Place> = [] {
        willSet {
            DispatchQueue.main.async {
                self.placesInFindedArea = self.placesInFindedAreaSet.sorted()
            }
        }
    }

    @Published var travelTime: String?
    @Published var isRoutePresenting: Bool = false
    @Published var showRouteButtonTitle: String = "Mostrar rota"
    @Published var showToast: Bool = false

    @Published var showFindInAreaButton: Bool = false
    var shouldShowFindInAreaButton: Bool {
        return !shouldShowPlacesFromSearch && showFindInAreaButton
    }

    @Published var showLocationServicesAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFirstLoading: Bool = true
    @Published var distance: CLLocationDistance = CLLocationDistance(3000)
    @Published var lastRegion: MKCoordinateRegion?
    @Published var lastContext: MapCameraUpdateContext?

    // MARK: Search

    @Published var searchText: String = "" {
        didSet { findAutocompletePredictions() }
    }
    @Published var isSearchBarVisible = false

    @Published var placesFromSearch: [Place] = []
    var shouldShowPlacesFromSearch: Bool {
        return !placesFromSearch.isEmpty && isSearchBarVisible
    }

    @Published var route: MKRoute? {
        didSet {
            let hasRoute = route != nil
            isRoutePresenting = hasRoute
            showRouteButtonTitle = hasRoute ? "Remover rota" : "Mostrar rota"
        }
    }

    var toastMessage: String = "Nenhum posto de recarga elétrica encontrado nesta área."

    func startCurrentLocationUpdates() async throws {
        try? await locationService.startCurrentLocationUpdates()
    }

    func updateDistance(with context: MapCameraUpdateContext) {
        distance = context.camera.distance / 3.8
    }

    func saveLast(_ context: MapCameraUpdateContext) {
        lastContext = context
    }

    func handleCamera(with context: MapCameraUpdateContext) {
        if position.positionedByUser {
            updateCameraPosition(forContext: context)

            withAnimation {
                showFindInAreaButton = true
            }
        }
    }

    /// Function to update camera position to fit all markers
    func getMapItemsRegion(places: [Place], completion: @escaping (MKCoordinateRegion) -> Void) {
        guard !places.isEmpty else { return }

        // Calculate the bounding region for all markers
        var minLat = places[0].geometry?.location?.lat ?? 0
        var maxLat = places[0].geometry?.location?.lat ?? 0
        var minLon = places[0].geometry?.location?.lng ?? 0
        var maxLon = places[0].geometry?.location?.lng ?? 0

        for item in places {
            minLat = min(minLat, item.geometry?.location?.lat ?? 0)
            maxLat = max(maxLat, item.geometry?.location?.lat ?? 0)
            minLon = min(minLon, item.geometry?.location?.lng ?? 0)
            maxLon = max(maxLon, item.geometry?.location?.lng ?? 0)
        }

        // Create a region that contains all markers
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.2, longitudeDelta: (maxLon - minLon) * 1.2)
        let newRegion = MKCoordinateRegion(center: center, span: span)

        completion(newRegion)
    }

    func onChangeOf(_ selectedPlaceID: String?) {
        guard let place = places.first(where: { $0.id == selectedPlaceID }) else { return }

        guard let lat = place.geometry?.location?.lat,
              let lng = place.geometry?.location?.lng else { return }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        let mapItem = MKMapItem(placemark: .init(coordinate: coordinate))
        updateCameraPosition(with: .item(mapItem))
    }

    func onMapCameraChange(_ context: MapCameraUpdateContext) {
        handleCamera(with: context)
        updateDistance(with: context)
        saveLast(context)
    }

    // MARK: Private

    enum Constants {
        static let defaultRadius: Float = 3000
        static let defaultCoordinate: CLLocationCoordinate2D = .init(latitude: -22.904232, longitude: -43.104371)
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    
    @Injected var locationService: LocationService

    private var provider = MoyaProvider<GoogleMapsAPI>(plugins: [NetworkConfig.networkLogger])
    
    private var cancellables = Set<AnyCancellable>()
    
    /// indicates if app should send camera update to map or not
    private var shouldUpdateCamera: Bool = true
    
    /// indicates when need fetch data from API, when it's false should stop fetching.
    private var shouldFetchStations: Bool = true

    private func bind() {
        locationService.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self, let location else { return }

                if shouldUpdateCamera {
                    shouldUpdateCamera = false
                    updateCameraPosition(forCoordinate: location.coordinate)
                }

                performFetchData(in: location.coordinate)
            }
            .store(in: &cancellables)
    }

    private func performFetchData(in coordinate: CLLocationCoordinate2D) {
        if shouldFetchStations {
            shouldFetchStations = false

            fetchStationsFromGooglePlaces(in: coordinate) { [weak self] places in
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

    private func updateLastRegion() {
        lastRegion = position.region
    }

    private let client = GMSPlacesClient.shared()

}

// MARK: Requests

extension MapViewModel {

    // MARK: GooglePlaces

    func fetchStationsFromGooglePlaces(in location: CLLocationCoordinate2D, completion: @escaping ([Place]?) -> Void) {
        isLoading = true

        provider.request(.eletricalChargingStations(location: location, radius: distance)) { [weak self] result in
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
                        self?.insert(place)
                        self?.insertPlacesInFindedArea(for: place)
                        completion(self?.placesInFindedArea)
                    }
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

    private func insert(_ place: Place) {
        placesSet.insert(place)
    }

    private func insertPlacesInFindedArea(for place: Place) {
        placesInFindedAreaSet.insert(place)
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

    func findAutocompletePredictions() {
        let filter = GMSAutocompleteFilter()
        filter.type = .address

        client.findAutocompletePredictions(
            fromQuery: searchText,
            filter: filter,
            sessionToken: nil) { [weak self] results, error in
                guard let self, let results, error == nil else { return }

                let places: [Place] = results.compactMap({ place in
                    Place(name: place.attributedFullText.string, placeID: place.placeID)
                })

                let sortedPlaces = places.sorted {
                    levenshteinDistance(from: $0.name?.lowercased() ?? "", to: self.searchText.lowercased()) <
                        levenshteinDistance(from: $1.name?.lowercased() ?? "", to: self.searchText.lowercased())
                }

                DispatchQueue.main.async {
                    self.placesFromSearch = sortedPlaces
                }
            }
    }

    // MARK: Get GooglePlace

    func getPlace(id: String?, completion: @escaping (Place?) -> Void) {
        guard let id else {
            printLog(.critical, "id is null")
            completion(nil)
            return
        }

        client.fetchPlace(fromPlaceID: id, placeFields: .all, sessionToken: nil) { [weak self] googlePlace, error in
            guard let self else { return }

            if let error {
                printLog(.critical, "\(error) - \(error.localizedDescription)")
                self.toastMessage = "\(error) - \(error.localizedDescription)"
            }

            guard let googlePlace else {
                printLog(.critical, "googlePlace is null")
                return
            }

            printLog(.error, "googlePlace = \(googlePlace)")
            
            let location = Location(lat: googlePlace.coordinate.latitude, lng: googlePlace.coordinate.longitude)
            let geometry = Geometry(location: location)
            let place = Place(geometry: geometry, name: googlePlace.name, placeID: googlePlace.placeID)
            completion(place)
        }
    }

    // MARK: Route

    func fetchRouteFrom(_ source: CLLocation, to destination: CLLocation) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = .automobile
        
        _Concurrency.Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            getTravelTime()
        }
    }
}

// MARK: UpdateCameraPosition

extension MapViewModel {
    func updateCameraPosition(with position: MapCameraPosition) {
        withAnimation {
            self.position = position
        }

        updateLastRegion()
    }

    func updateCameraPosition(forCoordinate coordinate: CLLocationCoordinate2D) {
        guard let span = position.region?.span else {
            printLog(.critical, "span is null")
            return
        }

        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: span
                )
            )
        }

        updateLastRegion()
    }

    func updateCameraPosition(forContext context: MapCameraUpdateContext) {
        position = .region(.init(center: context.region.center, span: context.region.span))

        if showToast {
            setShowToast(false)
        }

        updateLastRegion()
    }

    func updateCameraPosition(forRegion region: MKCoordinateRegion) {
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: region.center,
                    span: region.span
                )
            )
        }

        updateLastRegion()
    }
}

// Extension to determine if a coordinate is within a region
extension MKCoordinateRegion {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let latitudeDelta = span.latitudeDelta / 2.0
        let longitudeDelta = span.longitudeDelta / 2.0

        let latitudeRange = (center.latitude - latitudeDelta)...(center.latitude + latitudeDelta)
        let longitudeRange = (center.longitude - longitudeDelta)...(center.longitude + longitudeDelta)

        return latitudeRange.contains(coordinate.latitude) && longitudeRange.contains(coordinate.longitude)
    }
}


extension MKCoordinateRegion: Equatable {
    public static func ==(lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center == rhs.center && lhs.span == rhs.span
    }
}

extension MKCoordinateSpan: Equatable {
    public static func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        return lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


func levenshteinDistance(from s: String, to t: String) -> Int {
    let sCount = s.count
    let tCount = t.count
    var matrix = [[Int]](repeating: [Int](repeating: 0, count: tCount + 1), count: sCount + 1)

    for i in 0...sCount {
        matrix[i][0] = i
    }
    for j in 0...tCount {
        matrix[0][j] = j
    }

    for i in 1...sCount {
        for j in 1...tCount {
            let cost = (s[s.index(s.startIndex, offsetBy: i - 1)] == t[t.index(t.startIndex, offsetBy: j - 1)]) ? 0 : 1
            matrix[i][j] = min(min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1), matrix[i - 1][j - 1] + cost)
        }
    }

    return matrix[sCount][tCount]
}
