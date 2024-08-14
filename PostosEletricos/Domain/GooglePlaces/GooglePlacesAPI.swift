//
//  GooglePlacesAPI.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import Foundation
import Moya
import MapKit

enum GooglePlacesAPI {
    case searchNearby(location: CLLocationCoordinate2D, radius: Double)
    case details(id: String)
    case autocomplete(query: String, location: CLLocationCoordinate2D? = nil, radius: Double = 4000)
    case photo(maxWidth: Double, photoReference: String)
    case searchText(northEastCoordinate: CLLocationCoordinate2D, southWestCoordinate: CLLocationCoordinate2D)
}

extension GooglePlacesAPI: TargetType {

    var baseURL: URL { URL(string: "https://places.googleapis.com/v1")! }

    var path: String {
        switch self {
        case .searchNearby: return "places:searchNearby"
        case let .details(id): return "/places/\(id)"
        case .autocomplete: return "places:autocomplete"
        case .photo: return "/photo"
        case .searchText: return "/places:searchText"
        }
    }

    var method: Moya.Method {
        switch self {
        case .details, .photo:
            return .get

        case .searchNearby, .searchText, .autocomplete:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .searchNearby(location, radius):
            return .requestJSONEncodable(
                SearchNearbyRequest(
                    includedTypes: [PrimaryTypeEnum.electricVehicleChargingStation.rawValue],
                    locationRestriction: CircleLocationRestriction(
                        circle: LocationRestrictionCircle(
                            center: RequestCoordinate(latitude: location.latitude, longitude: location.longitude),
                            radius: radius
                        )
                    ),
                    languageCode: LanguageCodeEnum.ptBR.rawValue
                )
            )

        case .details:
            return .requestParameters(
                parameters: ["languageCode": LanguageCodeEnum.ptBR.rawValue],
                encoding: URLEncoding.queryString
            )

        case let .autocomplete(query, location, radius):
            if let location {
                return .requestJSONEncodable(
                    AutoCompleteRequest(
                        input: query,
                        locationBias: .init(circle: .init(center: .init(latitude: location.latitude, longitude: location.longitude), radius: radius)),
                        languageCode: LanguageCodeEnum.pt.rawValue,
                        origin: RequestCoordinate(latitude: LocationManager.shared.userLocation?.coordinate.latitude, longitude: LocationManager.shared.userLocation?.coordinate.longitude)
                    )
                )
            } else {
                return .requestJSONEncodable(
                    AutoCompleteRequest(
                        input: query,
                        languageCode: LanguageCodeEnum.pt.rawValue,
                        origin: RequestCoordinate(latitude: LocationManager.shared.userLocation?.coordinate.latitude, longitude: LocationManager.shared.userLocation?.coordinate.longitude)
                    )
                )
            }

        case let .photo(maxWidth, photoReference):
            return .requestParameters(
                parameters: [
                    "maxwidth": maxWidth,
                    "photoreference": photoReference,
                    "key" : SecretsKeys.googlePlaces.key,
                ],
                encoding: URLEncoding.default
            )

        case let .searchText(northEastCoordinate, southWestCoordinate):
            return .requestJSONEncodable(
                SearchTextRequest(
                    strictTypeFiltering: true,
                    includedType: PrimaryTypeEnum.electricVehicleChargingStation.rawValue,
                    locationRestriction: LocationRestriction(
                        rectangle: LocationRestrictionRectangle(
                            high: RequestCoordinate(latitude: northEastCoordinate.latitude, longitude: northEastCoordinate.longitude),
                            low: RequestCoordinate(latitude: southWestCoordinate.latitude, longitude: southWestCoordinate.longitude)
                        )
                    ),
                    textQuery: "EV",
                    languageCode: LanguageCodeEnum.pt.rawValue
                ))
        }
    }

    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "X-Goog-Api-Key": SecretsKeys.googlePlaces.key,
            "X-Goog-FieldMask": "*"
        ]
    }
}

// MARK: - Helpers

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return Data(utf8)
    }
}
