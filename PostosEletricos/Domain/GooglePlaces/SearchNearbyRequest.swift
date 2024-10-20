//
//  SearchNearbyRequest.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 05/06/24.
//

import Foundation

// MARK: - SearchNearbyRequest
struct SearchNearbyRequest: Encodable {
    let includedTypes: [String]
    let locationRestriction: CircleLocationRestriction
    let languageCode: String?
}

// MARK: - CircleLocationRestriction
struct CircleLocationRestriction: Encodable {
    let circle: LocationRestrictionCircle
}

// MARK: - LocationRestrictionCircle
struct LocationRestrictionCircle: Encodable {
    let center: RequestCoordinate
    let radius: Double
}
