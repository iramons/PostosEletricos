//
//  GooglePlacesResponse.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 26/01/24.
//

import Foundation

// MARK: - GooglePlacesResponse

struct GooglePlacesResponse: Codable {

    let htmlAttributions: [String]?
    let nextPageToken: String?
    let results: [Place]?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case nextPageToken = "next_page_token"
        case results
        case status
    }
}
