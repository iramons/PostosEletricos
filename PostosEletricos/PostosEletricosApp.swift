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

    @State private var showPulseUI: Bool = false

    init() {
        configureGooglePlaces()
        registerAllServices()
        enablePulseLogs()
    }

    private func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(Keys.googleMaps.rawValue)
    }

    var body: some Scene {
        WindowGroup {
            MapView()
                .onShakeGesture {
                    UIImpactFeedbackGenerator(style: .soft)
                        .impactOccurred()

                    withAnimation {
                        showPulseUI.toggle()
                    }
                }
                .sheet(isPresented: $showPulseUI) {
                    NavigationView {
                        ConsoleView()
                    }
                }
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
