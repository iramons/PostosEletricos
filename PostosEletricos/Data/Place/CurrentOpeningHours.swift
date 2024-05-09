//
//  CurrentOpeningHours.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/05/24.
//

import Foundation

// MARK: - CurrentOpeningHours

struct CurrentOpeningHours: Codable, Equatable, Hashable {

    let openNow: Bool?
    let weekdayText: [String]?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
    }
}
