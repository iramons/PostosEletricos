//
//  GooglePlaceResponse.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - GooglePlaceResponse

struct GooglePlaceResponse: Codable {
    let place: Place?

    enum CodingKeys: String, CodingKey {
        case place
    }
}
