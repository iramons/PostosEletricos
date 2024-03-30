//
//  PostosEletricosApp.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import GooglePlaces
import Pulse
import PulseUI

@main
struct PostosEletricosApp: App {

    init() {
        configureGooglePlaces()
        registerAllServices()
        enablePulseLogs()
    }

    private func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(SecretsKeys.googlePlaces.key)
    }

    var body: some Scene {
        WindowGroup {
            AnimatedSplashView()
        }
    }
}

// MARK: Pulse

private extension PostosEletricosApp {
    private func enablePulseLogs() {
        Experimental.URLSessionProxy.shared.isEnabled = true
        URLSessionProxyDelegate.enableAutomaticRegistration()
    }
}
