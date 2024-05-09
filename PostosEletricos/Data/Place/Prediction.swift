//
//  Prediction.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - Prediction

struct Prediction: Codable {

    let description: String?
    let matchedSubstrings: [MatchedSubstring]?
    let placeID, reference: String?
    let structuredFormatting: StructuredFormatting?
    let terms: [PredictionTerm]?
    let types: [String]?

    enum CodingKeys: String, CodingKey {
        case description
        case matchedSubstrings = "matched_substrings"
        case placeID = "place_id"
        case reference
        case structuredFormatting = "structured_formatting"
        case terms, types
    }
}

// MARK: - MatchedSubstring

struct MatchedSubstring: Codable {

    let length: Int?
    let offset: Int?
}

// MARK: - StructuredFormatting

struct StructuredFormatting: Codable {

    let mainText: String?
    let mainTextMatchedSubstrings: [MatchedSubstring]?
    let secondaryText: String?

    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case mainTextMatchedSubstrings = "main_text_matched_substrings"
        case secondaryText = "secondary_text"
    }
}

// MARK: - PredictionTerm

struct PredictionTerm: Codable {

    let offset: Int?
    let value: String?
}
