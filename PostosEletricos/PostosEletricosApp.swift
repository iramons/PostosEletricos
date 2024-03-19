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
    
    @State var showSplash: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    MapView()
                } else {
                    SplashView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSplash = true
                    }
                }
            }
        }
    }
}
