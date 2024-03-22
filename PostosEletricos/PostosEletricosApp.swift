//
//  PostosEletricosApp.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import GooglePlaces

@main
struct PostosEletricosApp: App {
    
    init() {
        configureGooglePlaces()
        registerAllServices()
     }
    
    private func configureGooglePlaces() {
        GMSPlacesClient.provideAPIKey(Keys.googleMaps.rawValue)
    }
    
    
    var body: some Scene {
        WindowGroup {
            MapView()
        }
    }
}
