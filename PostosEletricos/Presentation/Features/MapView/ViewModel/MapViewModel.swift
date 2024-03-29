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

@MainActor
class MapViewModel: ObservableObject {
    
    // MARK: Lifecycle
    
    init() {
        showLocationServicesAlert = locationService.showLocationServicesAlert
        
        bind()
    }

    // MARK: Public

    @State var state: FetchState = .none

    @Published var location: CLLocation?
    @Published var items: [MKMapItem] = [MKMapItem]()
    @Published var itemsInFindedArea: [MKMapItem] = [MKMapItem]()
    @Published var selectedItem: MKMapItem?
    @Published var travelTime: String?
    @Published var isRoutePresenting: Bool = false
    @Published var showRouteButtonTitle: String = "Mostrar rota"
    @Published var showToast: Bool = false
    @Published var showSplash: Bool = true
    @Published var showFindInAreaButton: Bool = false
    @Published var showLocationServicesAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var distance: CLLocationDistance = CLLocationDistance(3000)
    @Published var lastRegion: MKCoordinateRegion?
    @Published var lastContext: MapCameraUpdateContext?

    @Published var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(latitude: -20.4844352, longitude: -69.3907158),
            latitudinalMeters: CLLocationDistance(Constants.defaultRadius),
            longitudinalMeters: CLLocationDistance(Constants.defaultRadius)
        )
    )

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
    
    func updateCameraPosition(forCoordinate coordinate: CLLocationCoordinate2D) {
        guard let span = cameraPosition.region?.span else {
            printLog(.critical, "span is null")
            return
        }

        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: span
                )
            )
        }

        updateLastRegion()
    }
    
    func updateCameraPosition(forContext context: MapCameraUpdateContext) {
        cameraPosition = .region(.init(center: context.region.center, span: context.region.span))

        if showToast {
            setShowToast(false)
        }

        updateLastRegion()
    }

    func updateCameraPosition(forRegion region: MKCoordinateRegion) {
        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: region.center,
                    span: region.span
                )
            )
        }

        updateLastRegion()
    }

    func updateDistance(with context: MapCameraUpdateContext) {
        distance = context.camera.distance / 3.8
    }

    func saveLast(_ context: MapCameraUpdateContext) {
        lastContext = context
    }

    func handleCamera(with context: MapCameraUpdateContext) {
        if cameraPosition.positionedByUser {
            updateCameraPosition(forContext: context)
        }

        let itemsInRegion: [MKMapItem] = itemsInRegion(with: context)

        if itemsInRegion.isEmpty {
            showFindInAreaButton = true
        }
    }

    /// Function to update camera position to fit all markers
    func updateCameraPositionToFitMarkers(items: [MKMapItem]) {
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

        // Set the new region as the camera position
        updateCameraPosition(forRegion: newRegion)
    }

    func itemsInRegion(with context: MapCameraUpdateContext) -> [MKMapItem] {
        return items.filter { item in
            context.region.contains(coordinate: item.placemark.coordinate)
        }
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
                self.location = location
                performUpdateCamera()
                performFetchData(in: location.coordinate)
            }
            .store(in: &cancellables)
    }
    
    private func updateCameraPosition() {
        guard let location else { return }
        updateCameraPosition(forCoordinate: location.coordinate)
    }
    
    private func performUpdateCamera() {
        if shouldUpdateCamera {
            shouldUpdateCamera = false
            updateCameraPosition()
        }
    }
    
    private func performFetchData(in coordinate: CLLocationCoordinate2D) {
        if shouldFetchStations {
            shouldFetchStations = false

            fetchStationsFromGooglePlaces(in: coordinate) { [weak self] items in
                guard let self, let items else { return }
                updateCameraPositionToFitMarkers(items: items)

                _Concurrency.Task {
                    await self.fetchStationsFromMapKit() { itemsFromMapKit in
                        guard let itemsFromMapKit else { return }
                        self.updateCameraPositionToFitMarkers(items: itemsFromMapKit)
                    }
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
        lastRegion = cameraPosition.region
    }
}

// MARK: Request

extension MapViewModel {
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

                    if response.results.isEmpty {
                        printLog(.warning, "No results found in this area.")
                        setShowToast(true)
                    }

                    response.results.forEach { place in
                        guard let lat = place.geometry?.location?.lat,
                              let lng = place.geometry?.location?.lng
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
                    printLog(.error, "\(error)")
                    completion(nil)
                }

                isLoading = false
                showFindInAreaButton = false


            case let .failure(error):
                printLog(.error, "failure request: \(error)")
                isLoading = false
                showFindInAreaButton = false
                completion(nil)
            }
        }
    }
    
    func fetchStationsFromMapKit(completion: @escaping ([MKMapItem]?) -> Void) async {
        guard let region = cameraPosition.region else { return }
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = "eletric charge"
        let results = try? await MKLocalSearch(request: request).start()

        printLog(.error, "results = \(results)")

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


enum DatabaseType {
    case googlePlaces
    case mapKit
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: -20.4844352, longitude: -69.3907158)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(
            center: .userLocation,
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
    }
}
