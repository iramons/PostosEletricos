//
//  MapApps.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import UIKit
import CoreLocation
import SwiftUI

public enum MapApps {
    case appleMaps
    case googleMaps
    case waze
    case uber

    // MARK: Public

    public static let allValues: [MapApps] = [
        .appleMaps,
        .googleMaps,
        .waze,
        .uber,
    ]

    public static var availableServices: [MapApps] {
        return allValues.filter { $0.available && !exceptions.contains($0) }
    }

    /// Array of MapApps that should not show to user
    public static var exceptions: [MapApps] = []

    public var name: String {
        switch self {
        case .appleMaps:
            return "Apple Maps"
        case .googleMaps:
            return "Google Maps"
        case .waze:
            return "Waze"
        case .uber:
            return "Uber"
        }
    }

    public var urlString: String {
        switch self {
        case .appleMaps:
            return "http://maps.apple.com"
        case .googleMaps:
            return "comgooglemaps://"
        case .waze:
            return "waze://"
        case .uber:
            return "uber://"
        }
    }

    public var url: URL? {
        return URL(string: urlString)
    }

    public var available: Bool {
        guard let url = url else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    public func open(
        coordinates: CLLocationCoordinate2D,
        address: String,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let url = mapUrl(coordinates: coordinates, address: address) else {
            completion?(false)
            return
        }

        url.openURL()

        completion?(true)
    }

    // MARK: Private

    private func buildUrlString(
        coordinates: CLLocationCoordinate2D,
        address: String
    ) -> String {
        var urlString = self.urlString

        switch self {
        case .appleMaps,
             .googleMaps:
            urlString.append("?q=\(address)")
        case .waze:
            urlString.append("?ll=\(coordinates.latitude),\(coordinates.longitude)navigate=yes")
        case .uber:
            urlString.append("?action=setPickup&dropoff[latitude]=\(coordinates.latitude)&dropoff[longitude]=\(coordinates.longitude)&dropoff[formatted_address]=\(address)")
        }

        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString

        return urlwithPercentEscapes
    }

    private func mapUrl(coordinates: CLLocationCoordinate2D, address: String) -> URL? {
        let urlString = buildUrlString(coordinates: coordinates, address: address)
        return URL(string: urlString)
    }
}

// MARK: Refactored

enum MapApp: CaseIterable {
    case apple, googleMaps, uber, waze

    var title: String {
        switch self {
        case .apple: return "Apple Maps"
        case .googleMaps: return "Google Maps"
        case .waze: return "Waze"
        case .uber: return "Uber"
        }
    }

    var scheme: String {
        switch self {
        case .apple: return "http"
        case .googleMaps: return "comgooglemaps"
        case .waze: return "waze"
        case .uber: return "uber"
        }
    }

    var isInstalled: Bool {
        guard let url = URL(string: self.scheme.appending("://")) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    func url(for coordinate: CLLocationCoordinate2D?, address: String = "") -> URL? {
        guard let coordinate else { return nil }

        let latitude = coordinate.latitude
        let longitude = coordinate.longitude

        var urlString: String = ""

        switch self {
        case .apple:
            urlString = "\(scheme)://maps.apple.com/?daddr=\(latitude),\(longitude)"

        case .googleMaps:
            urlString = "\(scheme)://?daddr=\(latitude),\(longitude)&directionsmode=driving"

        case .waze:
            urlString = "\(scheme)://?ll=\(latitude),\(longitude)navigate=yes"

        case .uber:
            urlString = "\(scheme)://?action=setPickup&dropoff[latitude]=\(latitude)&dropoff[longitude]=\(longitude)&dropoff[formatted_address]=\(address)"
        }

        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString

        return URL(string: urlwithPercentEscapes)
    }

    func open(coordinate: CLLocationCoordinate2D, address: String = "") {
        guard let url = url(for: coordinate, address: address) else { return }
        url.openURL()
    }
}

extension View {
    func opensMap(at location: CLLocationCoordinate2D?) -> some View {
        return self.modifier(OpenMapViewModifier(location: location))
    }
}

struct OpenMapViewModifier: ViewModifier {

    var location: CLLocationCoordinate2D?

    @State private var showingAlert: Bool = false
    private let installedApps = MapApp.allCases.filter { $0.isInstalled }

    func body(content: Content) -> some View {
        Button(action: {
            if installedApps.count > 1 {
                showingAlert = true
            } else if let app = installedApps.first, let url = app.url(for: location) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) {
            content.confirmationDialog("Abrir com", isPresented: $showingAlert) {

                let appButtons: [ActionSheet.Button] = self.installedApps.compactMap { app in
                    guard let url = app.url(for: self.location) else { return nil }
                    return .default(Text(app.title)) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
//                return ActionSheet(title: Text("Navigate"), message: Text("Select an app..."), buttons: appButtons + [.cancel()])
            }
        }
    }
}
