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
    case eletricalChargingStations(location: CLLocationCoordinate2D, radius: Double)
}

extension GoogleMapsAPI: TargetType {
    var baseURL: URL { URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")! }
    
    var path: String {
        switch self {
        case .eletricalChargingStations:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
            
        case .eletricalChargingStations:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
            
        case let .eletricalChargingStations(location, radius):
            return .requestParameters(
                parameters: [
                    "location" : "\(location.latitude), \(location.longitude)",
                    "radius" : "\(radius)",
                    "key" : SecretsKeys.googlePlaces.key,
                    "keyword" : "electric+vehicle+charging+station+postos+eletricos"
                ],
                encoding: URLEncoding.default
            )
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
