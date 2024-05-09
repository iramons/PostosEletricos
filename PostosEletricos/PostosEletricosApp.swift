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

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var showMap: Bool = false

    var body: some Scene {
        WindowGroup {
            VStack(spacing: .zero) {
                if showMap {
                    MapView()
                } else {
                    LaunchView()
                }
            }
            .background(.darknessGreen)
            .onAppear {
                if !showMap {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeIn) {
                            showMap.toggle()
                        }
                    }
                }
            }
        }
    }
}
