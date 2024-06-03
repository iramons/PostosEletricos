//
//  AdCoordinator.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 01/06/24.
//

import Foundation
import GoogleMobileAds

// MARK: AdCoordinator

class AdCoordinator: NSObject, ObservableObject {

    private var ad: GADInterstitialAd?
    @Published var onDismissAd: Bool = false
    @Published var failedToLoadAd: Bool = false

    func loadAd() {
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()
        ) { ad, error in
            if let error {
                self.failedToLoadAd = true
                return printLog(.error, String(describing: error), verbose: true)
            }

            self.ad = ad
            self.ad?.fullScreenContentDelegate = self
        }
    }

    func presentAd() {
        guard let ad else {
            return print("Ad wasn't ready")
        }
        ad.present(fromRootViewController: nil)
    }
}

// MARK: GADFullScreenContentDelegate

extension AdCoordinator: GADFullScreenContentDelegate {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {}

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {}

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        onDismissAd = true
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {}

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {}

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        onDismissAd = true
        loadAd()
    }
}
