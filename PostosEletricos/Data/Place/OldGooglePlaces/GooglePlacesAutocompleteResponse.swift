//
//  GooglePlacesAutocompleteResponse.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - GooglePlacesAutocompleteResponse

struct GooglePlacesAutocompleteResponse: Decodable {
    let suggestions: [Suggestion]?
}