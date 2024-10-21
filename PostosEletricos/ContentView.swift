//
//  ContentView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 31/05/24.
//

import Foundation
import SwiftUI

#if DEBUG
import PulseUI
#endif

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showPulseUI: Bool = false

    var body: some View {
        VStack {
            switch navigationManager.currentView {
            case .launch:
                LaunchView()
                
            case .map:
                MapView()
            }
        }
        .sheet(isPresented: $showPulseUI) {
            #if DEBUG
            NavigationView {
                ConsoleView()
            }
            #endif
        }
        .onShakeGesture {
            #if DEBUG
            showPulseUI.toggle()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            #endif
        }
    }
}
