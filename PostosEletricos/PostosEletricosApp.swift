//
//  PostosEletricosApp.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import Resolver

@main
struct PostosEletricosApp: App {

    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}
