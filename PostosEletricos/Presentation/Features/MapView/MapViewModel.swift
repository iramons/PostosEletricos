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
    
    // MARK: Public

    @Published var items: [MKMapItem] = [MKMapItem]()
    
    @Published var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(latitude: -20.4844352, longitude: -69.3907158),
            latitudinalMeters: Constants.defaultDistance,
            longitudinalMeters: Constants.defaultDistance
        )
    )
        
//    func getLocationUpdates() {
//        locationService.$location
//            .sink { [weak self] newLocation in
//                guard let self, let newLocation else { return }
//                fetchEletricalChargingStations(in: newLocation)
//                updateCameraPosition(with: newLocation)
//            }
//            .store(in: &cancellables)
//    }
    
    init() {
        getLocationUpdates()
    }
    
    func getLocationUpdates() {
        let newLocation = CLLocationCoordinate2D(
            latitude: locationService2.location?.coordinate.latitude ?? 0,
            longitude: locationService2.location?.coordinate.longitude ?? 0
        )
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: newLocation,
                latitudinalMeters: Constants.defaultDistance,
                longitudinalMeters: Constants.defaultDistance
            )
        )
    }
    
    private func updateCameraPosition(with location: CLLocationCoordinate2D) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location,
                latitudinalMeters: Constants.defaultDistance,
                longitudinalMeters: Constants.defaultDistance
            )
        )
    }
    
    // MARK: Private
    
//    @Injected private var locationService: LocationManager
    @Injected var locationService2: LocationService

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
