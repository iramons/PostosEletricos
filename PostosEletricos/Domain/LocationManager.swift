//
//  LocationService.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 26/11/23.
//

import Foundation
import CoreLocation

// MARK: LocationService

final class LocationManager: NSObject, ObservableObject {
    
    // MARK: Public
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        
        setupLocationManager()
    }
    
    func requestLocation() {
        if locationManager?.authorizationStatus == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else {
            locationManager?.requestLocation()
        }
    }
    
    // MARK: Private
    
    private var locationManager: CLLocationManager?
    
    /// last location is used to know if new location is the same of the last
    private var lastLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func isValid(_ location: CLLocationCoordinate2D) -> Bool {
        return (location.latitude != lastLocation.latitude) && (location.longitude != lastLocation.longitude)
    }
}

// MARK: CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else {
            print("@@ location is not available.")
            return
        }
        
        if isValid(location) {
            self.location = location
            self.lastLocation = location
            
            print("@@ new location is lat:\(location.latitude) long:\(location.longitude)")
        }
     }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined,
             .restricted,
             .denied:
            manager.requestWhenInUseAuthorization()

        case .authorizedAlways,
             .authorizedWhenInUse:
            manager.startUpdatingLocation()

        @unknown default:
            fatalError("Unhandled authorization status: \(status)")
        }
    }
}

