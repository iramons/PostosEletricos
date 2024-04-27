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
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            showLocationServicesAlert = locationService.showLocationServicesAlert
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

    @Published var state: LoadingState = .idle
    @Published var selectedItem: MKMapItem?
    @Published var items: [MKMapItem] = [MKMapItem]()
    @Published var itemsInFindedArea: [MKMapItem] = [MKMapItem]()
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
    @Published var searchText: String = "" {
        didSet {
            findAutocompletePredictions()
        }
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
    func getMapItemsRegion(items: [MKMapItem], completion: @escaping (MKCoordinateRegion) -> Void) {
        guard !items.isEmpty else { return }

        // Calculate the bounding region for all markers
        var minLat = items[0].placemark.coordinate.latitude
        var maxLat = items[0].placemark.coordinate.latitude
        var minLon = items[0].placemark.coordinate.longitude
        var maxLon = items[0].placemark.coordinate.longitude

        for item in items {
            minLat = min(minLat, item.placemark.coordinate.latitude)
            maxLat = max(maxLat, item.placemark.coordinate.latitude)
            minLon = min(minLon, item.placemark.coordinate.longitude)
            maxLon = max(maxLon, item.placemark.coordinate.longitude)
        }

        // Create a region that contains all markers
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.2, longitudeDelta: (maxLon - minLon) * 1.2)
        let newRegion = MKCoordinateRegion(center: center, span: span)

        completion(newRegion)
    }

    func onChangeOf(_ selectedItem: MKMapItem?) {
        guard let selectedItem else { return }

        updateCameraPosition(with: .item(selectedItem))
    }

    func onMapCameraChange(_ context: MapCameraUpdateContext) {
        handleCamera(with: context)
        updateDistance(with: context)
        saveLast(context)
    }

    func onAppear() {

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

            fetchStationsFromGooglePlaces(in: coordinate) { [weak self] items in
                guard let self, let items else { return }

                getMapItemsRegion(items: items) { region in
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

    func fetchStationsFromGooglePlaces(in location: CLLocationCoordinate2D, completion: @escaping ([MKMapItem]?) -> Void) {
        isLoading = true

        provider.request(
            .eletricalChargingStations(
                latitude: location.latitude,
                longitude: location.longitude,
                radius: distance
            )
        ) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case let .success(response):
                strongSelf.itemsInFindedArea = []

                do {
                    let response = try response.map(GooglePlacesResponse.self, failsOnEmptyData: false)

                    guard let results = response.results, !results.isEmpty else {
                        printLog(.warning, "No results found in this area.")
                        strongSelf.setShowToast(true)
                        completion(nil)
                        return
                    }

                    results.forEach { [weak self] place in
                        guard let self,
                              let location = place.geometry?.location,
                              let lat = location.lat,
                              let lng = location.lng
                        else { return }

                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        let item = MKMapItem(placemark: .init(coordinate: coordinate))
                        item.name = place.name

                        withAnimation(.easeIn) {
                            self.items.append(item)
                            self.itemsInFindedArea.append(item)
                            completion(self.itemsInFindedArea)
                        }
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
                items.append(item)
                itemsInFindedArea.append(item)
            }
        }

        completion(itemsInFindedArea)
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
