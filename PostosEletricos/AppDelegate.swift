//
//  AppDelegate.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 21/04/24.
//

import Foundation
import UIKit
import GooglePlaces
import Resolver

#if DEBUG
import Pulse
#endif

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

//    @Injected private var locationService: LocationService
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureGooglePlaces()
        enablePulseLogs()
//
//        /// If location updates were previously active, restart them after the background launch.
//        if locationService.updatesStarted {
//            locationService.startLiveUpdates()
//        }
//
//        /// If a background activity session was previously active, reinstantiate it after the background launch.
//        if locationService.backgroundActivity {
//            locationService.backgroundActivity = true
//        }
        
        return true
    }

    private func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(SecretsKeys.googlePlaces.key)
    }
}

// MARK: Pulse

private extension AppDelegate {
    func enablePulseLogs() {
    #if DEBUG
        Experimental.URLSessionProxy.shared.isEnabled = true
        URLSessionProxyDelegate.enableAutomaticRegistration()
    #endif
    }
}
