//
//  Photo.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - Photo
struct Photo: Codable {
    let authorAttributions: [AuthorAttribution]?
    let heightPx: Int?
    let name: String?
    let widthPx: Int?

    init(
        authorAttributions: [AuthorAttribution]? = nil,
        heightPx: Int? = nil,
        name: String? = nil,
        widthPx: Int? = nil
    ) {
        self.authorAttributions = authorAttributions
        self.heightPx = heightPx
        self.name = name
        self.widthPx = widthPx
    }
}
