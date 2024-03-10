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
        updateCameraPosition()
        showLocationServicesAlert = locationService.showLocationServicesAlert
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

    private var cancellables = Set<AnyCancellable>()
    
    private var provider = MoyaProvider<GoogleMapsAPI>(plugins: [NetworkConfig.networkLogger])
    
    private enum Constants {
        static let defaultRadius: Float = 3000
        static let defaultDistance: CLLocationDistance = CLLocationDistance(defaultRadius)
    }
    
    /// if pass a location, will move to this location, else go to userLocation
    private func updateCameraPosition(with location: CLLocation? = nil) {
        if let location {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: Constants.defaultDistance,
                    longitudinalMeters: Constants.defaultDistance
                )
            )
            
            fetchEletricalChargingStations(in: location.coordinate)
        }
        else {
            guard let userLocation = locationService.location else {
                print("@@ userLocation is null.")
                return
            }
            
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: userLocation.coordinate,
                    latitudinalMeters: Constants.defaultDistance,
                    longitudinalMeters: Constants.defaultDistance
                )
            )
            
            fetchEletricalChargingStations(in: userLocation.coordinate)
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
                        
                        items.append(
                            MKMapItem(
                                placemark:
                                    MKPlacemark(
                                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    )
                            )
                        )
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
