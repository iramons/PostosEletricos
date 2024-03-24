//
//  GoogleMapsAPI.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import Foundation
import Moya

enum GoogleMapsAPI {
    case eletricalChargingStations(latitude: Double, longitude: Double, radius: Double)
}

extension GoogleMapsAPI: TargetType {
    var baseURL: URL { URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")! }
    
    var path: String {
        switch self {
        case .eletricalChargingStations:
            return ""
        }
    }
    
// https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=YOUR_LATITUDE,YOUR_LONGITUDE&radius=YOUR_RADIUS&keyword=electric+vehicle+charging+station&key=YOUR_API_KEY
// https://maps.googleapis.com/maps/api/place/nearbysearch/json/keyword=electric+vehicle+charging+station?key=AIzaSyBJsnPh525iU9dzOEdq7HA8Mcigcm2xZjI&location=34.011286%2C-116.166868&radius=12.0
// https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyBJsnPh525iU9dzOEdq7HA8Mcigcm2xZjI&keyword=electric%2Bvehicle%2Bcharging%2Bstation&location=34.011286%2C-116.166868&radius=12.0
    
    var method: Moya.Method {
        switch self {
            
        case .eletricalChargingStations:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
            
        case let .eletricalChargingStations(latitude, longitude, radius):
            return .requestParameters(
                parameters: [
                    "location" : "\(latitude), \(longitude)",
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
