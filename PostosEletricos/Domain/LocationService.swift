//
//  LocationService.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import CoreLocation

@Observable
final class LocationService {
    var location: CLLocation? = nil
    
    private let locationManager = CLLocationManager()

    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        for try await locationUpdates in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdates.location else { return }
            
            self.location = location
        }
    }
}
