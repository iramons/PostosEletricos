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
    
    @Published var items: [MKMapItem] = [MKMapItem]()
    
    @Published var showLocationServicesAlert: Bool = false
    
    @Published var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(latitude: -20.4844352, longitude: -69.3907158),
            latitudinalMeters: Constants.defaultDistance,
            longitudinalMeters: Constants.defaultDistance
        )
    )

    func startCurrentLocationUpdates() async throws {
        try? await locationService.startCurrentLocationUpdates()
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
                performUpdateCamera(with: location)
                performFetchData(in: location.coordinate)
            }
            .store(in: &cancellables)
    }
    
    private func updateCameraPosition(with location: CLLocation) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: Constants.defaultDistance,
                longitudinalMeters: Constants.defaultDistance
            )
        )
    }
    
    private func performUpdateCamera(with location: CLLocation) {
        if shouldUpdateCamera {
            shouldUpdateCamera = false
            updateCameraPosition(with: location)
        }
    }
    
    private func performFetchData(in coordinate: CLLocationCoordinate2D) {
        if shouldFetchStations {
            shouldFetchStations = false
            fetchEletricalChargingStations(in: coordinate)
        }
    }
}

// MARK: API

extension MapViewModel {
    func fetchEletricalChargingStations(in location: CLLocationCoordinate2D) {
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
}