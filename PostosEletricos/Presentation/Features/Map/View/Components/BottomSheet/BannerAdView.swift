//
//  BannerAdView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 22/05/24.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

// MARK: - BannerAdView

struct BannerAdView: UIViewControllerRepresentable {

    let bannerView = GADBannerView(adSize: GADAdSizeBanner)

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        bannerView.adUnitID = SecretsKeys.googleADSKey
        bannerView.rootViewController = viewController
        bannerView.isAutoloadEnabled = true

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

// MARK: - Preview

#Preview {
    BannerAdView()
        .background(.gray.opacity(0.5))
        .frame(width: .infinity, height: 50)
}
