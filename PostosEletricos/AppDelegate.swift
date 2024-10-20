//
//  AppDelegate.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 21/04/24.
//

import Foundation
import UIKit
import GoogleMobileAds

#if DEBUG
import Pulse
import PulseProxy
#endif

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    var window: UIWindow?

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        configureGoogleAds()
        enablePulseLogs()

        return true
    }
}

// MARK: Configurations

extension AppDelegate {
    private func configureGoogleAds() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

// MARK: Pulse

private extension AppDelegate {
    func enablePulseLogs() {
        #if DEBUG
        NetworkLogger.enableProxy()
        RemoteLogger.shared.isAutomaticConnectionEnabled = true
        #endif
    }
}
