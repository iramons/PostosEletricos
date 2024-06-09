//
//  AutoCompleteRequest.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 05/06/24.
//

import Foundation

// MARK: - AutoCompleteRequest

struct AutoCompleteRequest: Encodable {
    let input: String
    let locationBias: CircleLocationRestriction?
    let locationRestriction: LocationRestriction?
    let includedPrimaryTypes: [String]?
    let includedRegionCodes: [String]?
    let languageCode: String?
    let regionCode: String?
    let origin: RequestCoordinate?
    let inputOffset: Int?
    let includeQueryPredictions: Bool?
    let sessionToken: String?

    init(
        input: String,
        locationBias: CircleLocationRestriction? = nil,
        locationRestriction: LocationRestriction? = nil,
        includedPrimaryTypes: [String]? = nil,
        includedRegionCodes: [String]? = nil,
        languageCode: String? = nil,
        regionCode: String? = nil,
        origin: RequestCoordinate? = nil,
        inputOffset: Int? = nil,
        includeQueryPredictions: Bool? = nil,
        sessionToken: String? = nil
    ) {
        self.input = input
        self.locationBias = locationBias
        self.locationRestriction = locationRestriction
        self.includedPrimaryTypes = includedPrimaryTypes
        self.includedRegionCodes = includedRegionCodes
        self.languageCode = languageCode
        self.regionCode = regionCode
        self.origin = origin
        self.inputOffset = inputOffset
        self.includeQueryPredictions = includeQueryPredictions
        self.sessionToken = sessionToken
    }
}
