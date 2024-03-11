//
//  MapApps.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import UIKit
import CoreLocation

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
