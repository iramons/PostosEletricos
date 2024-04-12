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
        withAnimation {
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
    @Published var showLocationServicesAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFirstLoading: Bool = true
    @Published var distance: CLLocationDistance = CLLocationDistance(3000)
    @Published var lastRegion: MKCoordinateRegion?
    @Published var lastContext: MapCameraUpdateContext?
    @Published var searchText: String = ""
    @Published var isSearchBarVisible = false
    @Published var placesFromSearch: [Place] = []

    @Published var route: MKRoute? {
        didSet {
            let hasRoute = route != nil
            isRoutePresenting = hasRoute
            showRouteButtonTitle = hasRoute ? "Remover rota" : "Mostrar rota"
        }
    }

    let toastMessage: String = "Nenhum posto de recarga elétrica encontrado nesta área."

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

            showFindInAreaButton = true
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
    func findAutocompletePredictions(in location: CLLocationCoordinate2D, completion: @escaping ([Place]?) -> Void) {
        let filter = GMSAutocompleteFilter()

        client
            .findAutocompletePredictions(
                fromQuery: "electric+vehicle+charging+station+postos+eletricos",
                filter: filter,
                sessionToken: nil) { results, error in
                    guard let results, error == nil else {
                        completion(nil)
                        return
                    }

                    let places: [Place] = results.compactMap({ place in
                        printLog(.critical, "attributedFullText = \(place.attributedFullText.string)")
                        return Place(name: place.attributedFullText.string, placeID: place.placeID)
                    })

                    completion(places)
                }
    }

    func lookUpPlaceID(location: CLLocationCoordinate2D, completion: @escaping ([MKMapItem]?) -> Void) {
        findAutocompletePredictions(in: location) { [weak self] places in
            guard let places else { return }

            // Initialize a dispatch group
            let group = DispatchGroup()

            DispatchQueue.main.async {
                places.forEach { place in
                    // Enter the group before starting the asynchronous operation
                    group.enter()

                    self?.client.lookUpPlaceID(place.placeID ?? "") { googlePlace, error in
                        defer { group.leave() } // Ensure we leave the group whether or not there is an error

                        guard let coordinate = googlePlace?.coordinate else { return }
                        let item = MKMapItem(placemark: .init(coordinate: coordinate))
                        item.name = place.name

                        withAnimation {
                            self?.items.append(item)
                            self?.itemsInFindedArea.append(item)
                        }
                    }
                }

                // Call the completion block after all items have been processed
                group.notify(queue: .main) {
                    completion(self?.itemsInFindedArea)
                    self?.isLoading = false
                }
            }
        }
    }

    func fetchStationsFromGooglePlaces(in location: CLLocationCoordinate2D, completion: @escaping ([MKMapItem]?) -> Void) {
        isLoading = true

        provider.request(
            .eletricalChargingStations(
                latitude: location.latitude,
                longitude: location.longitude,
                radius: distance
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(response):
                itemsInFindedArea = []

                do {
                    let response = try response.map(GooglePlacesResponse.self, failsOnEmptyData: false)

                    guard let results = response.results, !results.isEmpty else {
                        printLog(.warning, "No results found in this area.")
                        setShowToast(true)
                        completion(nil)
                        return
                    }

                    results.forEach { place in
                        guard let location = place.geometry?.location,
                              let lat = location.lat,
                              let lng = location.lng
                        else { return }

                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        let item = MKMapItem(placemark: .init(coordinate: coordinate))
                        item.name = place.name

                        withAnimation {
                            self.items.append(item)
                            self.itemsInFindedArea.append(item)
                        }
                    }

                    completion(itemsInFindedArea)
                }
                catch {
                    printLog(.error, "\(error) - \(error.localizedDescription)")
                    completion(nil)
                }

                isLoading = false

            case let .failure(error):
                printLog(.error, "failure request: \(error) - \(error.localizedDescription)")
                isLoading = false
                completion(nil)
            }

            isFirstLoading = false
        }
    }
    
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
