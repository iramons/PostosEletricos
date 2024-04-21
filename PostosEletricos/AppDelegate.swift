//
//  AppDelegate.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 21/04/24.
//

import Foundation
import UIKit
import Pulse
import GooglePlaces

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureGooglePlaces()
        registerAllServices()
        enablePulseLogs()

        return true
    }

    private func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(SecretsKeys.googlePlaces.key)
    }
}

// MARK: Pulse

private extension AppDelegate {
    func enablePulseLogs() {
        Experimental.URLSessionProxy.shared.isEnabled = true
        URLSessionProxyDelegate.enableAutomaticRegistration()
    }
}
