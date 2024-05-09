//
//  Photo.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - Photo

struct Photo: Codable, Equatable, Hashable {

    let width: Double?
    let height: Double?
    let htmlAttributions: [String]?
    let photoReference: String?

    enum CodingKeys: String, CodingKey {
        case width, height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
    }

    init(
        width: Double? = nil,
        height: Double? = nil,
        htmlAttributions: [String]? = nil,
        photoReference: String? = nil
    ) {
        self.width = width
        self.height = height
        self.htmlAttributions = htmlAttributions
        self.photoReference = photoReference
    }
}
