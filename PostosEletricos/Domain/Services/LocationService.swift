//
//  LocationService.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import CoreLocation
import SwiftUI

@Observable
class LocationService: NSObject {

    var userLocation: CLLocation?
    var userHeading: CLHeading?
    var isAuthorized: Bool = false
    var isDenied: Bool = false
    var showSecondAlert: Bool = false

    private let locationManager = CLLocationManager()
    private var background: CLBackgroundActivitySession?
    private var lastAuthorizationStatus: CLAuthorizationStatus?

    /// last location is used to know if new location is the same of the last
    private var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)

    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
    }

    var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
        didSet {
            backgroundActivity ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
            UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
        }
    }

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        lastAuthorizationStatus = locationManager.authorizationStatus
    }

    func checkLocationAuthorization(status: CLAuthorizationStatus? = nil) {
        let currentStatus = status ?? locationManager.authorizationStatus

        switch currentStatus {
        case .notDetermined:
            withAnimation { isAuthorized = false }
            /// should not request authorization here

        case .restricted, .denied:
            withAnimation { isDenied = true }
            withAnimation { isAuthorized = false }
            stopLiveUpdates()

            if currentStatus == lastAuthorizationStatus {
                withAnimation { showSecondAlert = true }
            }

        case .authorizedAlways, .authorizedWhenInUse:
            withAnimation { isAuthorized = true }

            if !updatesStarted {
                startLiveUpdates()
            }

            /// Check if heading data is available.
            if CLLocationManager.headingAvailable() {
                locationManager.startUpdatingHeading()
            }

        @unknown default:
            withAnimation { isAuthorized = false }
            fatalError("Unhandled case in userLocation authorization status: \(currentStatus)")
        }
    }

    func startLiveUpdates() {
        guard isAuthorized else { return }

        Task {
            do {
                updatesStarted = true

                let liveUpdates = CLLocationUpdate.liveUpdates()

                for try await update in liveUpdates {
                    if !updatesStarted { break }  /// End location updates by breaking out of the loop.

                    guard let location = update.location else { return }

                    if !update.isStationary, isValid(location) {
                        DispatchQueue.main.async {
                            self.userLocation = location
                            self.lastLocation = location
                        }

                        printLog(.notice, "userLocation is lat:\(location.coordinate.latitude) long:\(location.coordinate.longitude)")
                    }
                }
            } catch {
                printLog(.error, String(describing: error), verbose: true)
            }
        }
    }
    
    func stopLiveUpdates() {
        updatesStarted = false
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    private func isValid(_ location: CLLocation) -> Bool {
        location.coordinate.latitude != lastLocation.coordinate.latitude &&
        location.coordinate.longitude != lastLocation.coordinate.longitude
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.userHeading = newHeading
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        lastAuthorizationStatus = manager.authorizationStatus

        checkLocationAuthorization(status: manager.authorizationStatus)
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

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
            withAnimation { showSecondAlert = true }

        case .network:
            printLog(.error, "Network error: \(clError.localizedDescription)", verbose: true)

        case .deferredFailed, .deferredNotUpdatingLocation, .deferredAccuracyTooLow, .deferredDistanceFiltered:
            printLog(.error, "Deferred location error: \(clError.localizedDescription)", verbose: true)

        default:
            printLog(.error, "Other Core Location error: \(clError.localizedDescription)", verbose: true)
        }
    }
}
