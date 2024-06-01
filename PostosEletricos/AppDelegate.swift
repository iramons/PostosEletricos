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
import GoogleMobileAds

#if DEBUG
import Pulse
#endif

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    var window: UIWindow?

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        configureGooglePlaces()
        configureGoogleAds()
        enablePulseLogs()

        return true
    }
}

// MARK: Configurations

extension AppDelegate {
    private func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(SecretsKeys.googlePlaces.key)
    }

    private func configureGoogleAds() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
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
