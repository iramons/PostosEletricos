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
    
    @Published var location: CLLocation?
    
    @Published var items: [MKMapItem] = [MKMapItem]()
    
    @Published var selectedItem: MKMapItem?
    
    @Published var showLocationServicesAlert: Bool = false
    
    @Published var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(latitude: -20.4844352, longitude: -69.3907158),
            latitudinalMeters: Constants.defaultDistance,
            longitudinalMeters: Constants.defaultDistance
        )
    )
        
    @Published var route: MKRoute? {
        didSet {
            let hasRoute = route != nil
            isRoutePresenting = hasRoute
            showRouteButtonTitle = hasRoute ? "Remover rota" : "Mostrar rota"
        }
    }
    
    @Published var travelTime: String?
    
    @Published var showRouteButtonTitle: String = "Mostrar rota"
    
    @Published var isRoutePresenting: Bool = false
    
    func startCurrentLocationUpdates() async throws {
        try? await locationService.startCurrentLocationUpdates()
    }
    
    func updateCamera(to location: CLLocation) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: Constants.defaultDistance,
                longitudinalMeters: Constants.defaultDistance
            )
        )
    }
    
    // MARK: Private
    
    @Injected var locationService: LocationService

    private var provider = MoyaProvider<GoogleMapsAPI>(plugins: [NetworkConfig.networkLogger])
    
    private var cancellables = Set<AnyCancellable>()
    
    /// indicates if app should send camera update to map or not
    private var shouldUpdateCamera: Bool = true
    
    /// indicates when need fetch data from API, when it's false should stop fetching.
    private var shouldFetchStations: Bool = true
    
    private enum Constants {
        static let defaultRadius: Float = 3000
        static let defaultDistance: CLLocationDistance = CLLocationDistance(defaultRadius)
    }
    
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
        updateCamera(to: location)
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
            fetchStations(in: coordinate)
        }
    }
    
    private func getTravelTime() {
        guard let route else { return }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }
}

// MARK: Request

extension MapViewModel {
    func fetchStations(in location: CLLocationCoordinate2D) {
        provider.request(
            .eletricalChargingStations(
                latitude: location.latitude,
                longitude: location.longitude,
                radius: Constants.defaultRadius
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(response):
                do {
                    let googlePlaces = try response.map(GooglePlaces.self, failsOnEmptyData: false)
                    
                    for place in googlePlaces.results {
                        guard let latitude = place.geometry?.location?.lat,
                              let longitude = place.geometry?.location?.lng else {
                            return
                        }
                    
                        let item = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
                        item.name = place.vicinity
                        
                        items.append(item)
                    }
                }
                catch {
                    print("error in success response: ", error)
                }
                
            case let .failure(error):
                print("failure request: ", error)
            }
        }
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
