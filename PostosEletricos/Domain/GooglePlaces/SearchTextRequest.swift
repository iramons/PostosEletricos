//
//  SearchTextRequest.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 03/06/24.
//

import Foundation

// MARK: - SearchTextRequest
struct SearchTextRequest: Codable {
    let strictTypeFiltering: Bool?
    let includedType: String?
    let locationRestriction: LocationRestriction?
    let textQuery, languageCode, rankPreference: String?

    init(
        strictTypeFiltering: Bool? = nil,
        includedType: String? = nil,
        locationRestriction: LocationRestriction? = nil,
        textQuery: String? = nil,
        languageCode: String? = nil,
        rankPreference: String? = nil
    ) {
        self.strictTypeFiltering = strictTypeFiltering
        self.includedType = includedType
        self.locationRestriction = locationRestriction
        self.textQuery = textQuery
        self.languageCode = languageCode
        self.rankPreference = rankPreference
    }
}

// MARK: - LocationRestriction
struct LocationRestriction: Codable {
    let rectangle: LocationRestrictionRectangle?
}

// MARK: - LocationRestrictionRectangle
struct LocationRestrictionRectangle: Codable {
    let high, low: RequestCoordinate?
}

// MARK: - RequestCoordinate
struct RequestCoordinate: Codable {
    let latitude, longitude: Double?
}
