//
//  GooglePlacesResponse.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 26/01/24.
//

import Foundation

// MARK: - GooglePlacesResponse

struct GooglePlacesResponse: Codable {
    let contextualContents: [ContextualContent]?
    let nextPageToken: String?
    let places: [Place]?
}
