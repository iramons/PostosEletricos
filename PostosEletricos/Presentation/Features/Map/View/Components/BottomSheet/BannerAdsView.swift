//
//  BannerAdView.swift
//  PostosEletricos
//
//  Created by Sportheca Brasil on 22/05/24.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdsView: UIViewControllerRepresentable {

    let bannerView = GADBannerView(adSize: GADAdSizeBanner)

    func makeUIViewController(context: Context) -> UIViewController {

        let viewController = UIViewController()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)

        bannerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
        ])

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        bannerView.load(GADRequest())
    }
}

#Preview {
    BannerAdsView()
        .background(.gray.opacity(0.5))
        .frame(width: .infinity, height: 50)
}
