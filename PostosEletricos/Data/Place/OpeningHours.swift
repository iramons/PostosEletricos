//
//  OpeningHours.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - OpeningHours

struct OpeningHours: Codable, Equatable, Hashable {
    
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}
