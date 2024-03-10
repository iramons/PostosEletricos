//
//  LocationService.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import CoreLocation

@Observable
final class LocationService: NSObject {
    var location: CLLocation? = nil
    
    private let locationManager = CLLocationManager()
    
    var showLocationServicesAlert = false
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        Task {
            try? await checkLocationAuthorization(status: locationManager.authorizationStatus)
        }
    }

    func startCurrentLocationUpdates() async throws {
        for try await liveUpdates in CLLocationUpdate.liveUpdates() {
            guard let location = liveUpdates.location else { return }
            
            if isValid(location) {
                self.location = location
                self.lastLocation = location
                
                print("@@ new location is lat:\(location.coordinate.latitude) long:\(location.coordinate.longitude)")
            }
        }
    }
    
    /// last location is used to know if new location is the same of the last
    private var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    private func isValid(_ location: CLLocation) -> Bool {
        location.coordinate.latitude != lastLocation.coordinate.latitude &&
        location.coordinate.longitude != lastLocation.coordinate.longitude
    }
    
    private func checkLocationAuthorization(status: CLAuthorizationStatus) async throws {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            showLocationServicesAlert = true
            
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        @unknown default:
            fatalError("Unhandled case in location authorization status: \(status)")
        }
    }
}
