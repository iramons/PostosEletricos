//
//  GoogleMapsAPI.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import Foundation
import Moya
import MapKit

enum GoogleMapsAPI {
    case places(location: CLLocationCoordinate2D, radius: Double)
    case place(placeID: String)
    case autocomplete(query: String, location: CLLocationCoordinate2D? = nil, radius: Double = 100000)
}

extension GoogleMapsAPI: TargetType {

    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api/place")!
    }

    var path: String {
        switch self {
        case .places:
            return "/nearbysearch/json"
        case .place:
            return "/details/json"
        case .autocomplete:
            return "/autocomplete/json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .places,
             .place,
             .autocomplete:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .places(location, radius):
            return .requestParameters(
                parameters: [
                    "location": "\(location.latitude), \(location.longitude)",
                    "radius": "\(radius)",
                    "key": SecretsKeys.googlePlaces.key,
                    "keyword": "electric+vehicle+charging+station+postos+eletricos",
                    "language": "pt-br"
                ],
                encoding: URLEncoding.default
            )

        case let .place(placeID):
            return .requestParameters(
                parameters: [
                    "place_id": placeID,
                    "key" : SecretsKeys.googlePlaces.key,
                    "language": "pt-br"
                ],
                encoding: URLEncoding.default
            )

        case let .autocomplete(query, location, radius):
            if let location {
                return .requestParameters(
                    parameters: [
                        "input": query,
                        "location": "\(location.latitude), \(location.longitude)",
                        "radius": "\(radius)",
                        "key": SecretsKeys.googlePlaces.key,
                        "language": "pt-br"
                    ],
                    encoding: URLEncoding.default
                )
            } else {
                return .requestParameters(
                    parameters: [
                        "input": query,
                        "key": SecretsKeys.googlePlaces.key,
                        "language": "pt-br"
                    ],
                    encoding: URLEncoding.default
                )
            }
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - Helpers

private extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data { Data(self.utf8) }
}
