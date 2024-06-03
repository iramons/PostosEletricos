//
//  GooglePlaceResponse.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - GooglePlaceResponse

struct GooglePlaceResponse: Codable {

    let htmlAttributions: [String]?
    let nextPageToken: String?
    let result: Place?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case nextPageToken = "next_page_token"
        case result
        case status
    }
}
