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
    
    @Published var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(latitude: -20.4844352, longitude: -69.3907158),
            latitudinalMeters: Constants.defaultDistance,
            longitudinalMeters: Constants.defaultDistance
        )
    )
    
    @Published var showLocationServicesAlert: Bool = false
    
    func startCurrentLocationUpdates() async throws {
        try? await locationService.startCurrentLocationUpdates()
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
        }
    }
    
    // MARK: Private
    
    @Injected var locationService: LocationService

    private var cancellables = Set<AnyCancellable>()
    
    private var provider = MoyaProvider<GoogleMapsAPI>(plugins: [NetworkConfig.networkLogger])
    
    private enum Constants {
        static let defaultRadius: Float = 3000
        static let defaultDistance: CLLocationDistance = CLLocationDistance(defaultRadius)
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
        ) { result in
            switch result {
            case let .success(moyaResponse):
                print("moyaResponse: ", moyaResponse)
                do {
                    let json = try moyaResponse.mapJSON()
                    print("JSON: ", json)
                    
                    let googlePlaces = try moyaResponse.map(GooglePlaces.self, failsOnEmptyData: false)
                    
                    for place in googlePlaces.results {
                        guard let lat = place.geometry?.location?.lat,
                              let lng = place.geometry?.location?.lng else {
                            print("lat or lng is null.")
                            return
                        }
                        
                        self.items.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))))
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
