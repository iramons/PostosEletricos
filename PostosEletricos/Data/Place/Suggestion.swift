//
//  Suggestion.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - Suggestion

struct Suggestion: Decodable {
    let placePrediction: PlacePrediction?
}

// MARK: - PlacePrediction

struct PlacePrediction: Decodable {
    let distanceMeters: Double?
    let place, placeID: String?
    let structuredFormat: StructuredFormat?
    let text: PlacePredictionText?
    let types: [String]?

    enum CodingKeys: String, CodingKey {
        case distanceMeters, place
        case placeID = "placeId"
        case structuredFormat, text, types
    }
}

// MARK: - StructuredFormat

struct StructuredFormat: Decodable {
    let mainText: PlacePredictionText?
    let secondaryText: SecondaryText?
}

// MARK: - PlacePredictionText

struct PlacePredictionText: Decodable {
    let matches: [Match]?
    let text: String?
}

// MARK: - Match

struct Match: Decodable {
    let endOffset, startOffset: Int?
}

// MARK: - SecondaryText

struct SecondaryText: Decodable {
    let text: String?
}
