//
//  LocationManager.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 19/05/24.
//

import SwiftUI
import Foundation
import CoreLocation

// MARK: LocationManager

final class LocationManager: NSObject, ObservableObject {

    static let shared = LocationManager()

    @Published var userLocation: CLLocation? = nil
    @Published var userRegion: CLCircularRegion?
    @Published var userHeading: CLHeading?
    @Published var isAuthorized: Bool = false
    @Published var isDenied: Bool = false
    @Published var showSecondAlert: Bool = false

    private var locationManager = CLLocationManager()
    private var authorizationStatus: CLAuthorizationStatus?
    private var lastAuthorizationStatus: CLAuthorizationStatus?
    private var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        lastAuthorizationStatus = locationManager.authorizationStatus
    }

    func requestAuthorization() {
        let currentStatus = locationManager.authorizationStatus

        if currentStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            handleAuthorizationStatus(currentStatus)
        }
    }

    func handleAuthorizationStatus(_ status: CLAuthorizationStatus? = nil) {
        let currentStatus = status ?? locationManager.authorizationStatus

        switch currentStatus {
        case .notDetermined:
            DispatchQueue.main.async { self.isAuthorized = false }
            /// Note: should not requestWhenInUseAuthorization() here

        case .restricted, .denied:
            locationManager.stopUpdatingLocation()

            DispatchQueue.main.async {
                self.isDenied = true
                self.isAuthorized = false
            }

            if currentStatus == lastAuthorizationStatus {
                DispatchQueue.main.async { self.showSecondAlert = true }
            }

        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()

            if CLLocationManager.headingAvailable() {
                locationManager.startUpdatingHeading()
            }

            DispatchQueue.main.async { self.isAuthorized = true }

        @unknown default:
            DispatchQueue.main.async { self.isAuthorized = false }
            fatalError("Unhandled case in userLocation authorization status: \(currentStatus)")
        }
    }

    private func isValid(_ location: CLLocation) -> Bool {
        // Should check if new location is different of the last
        location.coordinate.latitude != lastLocation.coordinate.latitude &&
        location.coordinate.longitude != lastLocation.coordinate.longitude
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    // MARK: Location

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if isValid(location) {
            DispatchQueue.main.async {
                self.userLocation = location
                self.lastLocation = location
                self.userRegion = CLCircularRegion(
                    center: location.coordinate,
                    radius: CLLocationDistance(10000),
                    identifier: "userRegion"
                )
            }

            printLog(.notice, "userLocation is lat:\(location.coordinate.latitude) long:\(location.coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        handleAuthorizationStatus(status)
    }

    // MARK: Heading

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.userHeading = newHeading
        }
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

    // MARK: Errors

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else {
            printLog(.error, "No CoreLocation error! Error is: \(error)", verbose: true)
            return
        }

        switch clError.code {
        case .locationUnknown:
            printLog(.error, "Location unknown: \(clError.localizedDescription)", verbose: true)

        case .denied:
            printLog(.error, "Location services denied: \(clError.localizedDescription)", verbose: true)
            DispatchQueue.main.async { self.showSecondAlert = true }

        case .network:
            printLog(.error, "Network error: \(clError.localizedDescription)", verbose: true)

        case .deferredFailed, .deferredNotUpdatingLocation, .deferredAccuracyTooLow, .deferredDistanceFiltered:
            printLog(.error, "Deferred location error: \(clError.localizedDescription)", verbose: true)

        default:
            printLog(.error, "Other Core Location error: \(clError.localizedDescription)", verbose: true)
        }
    }
}
