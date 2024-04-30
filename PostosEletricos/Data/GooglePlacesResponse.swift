//
//  GooglePlaces.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 26/01/24.
//

import Foundation

// MARK: - GooglePlacesResponse

struct GooglePlacesResponse: Codable {
    let nextPageToken: String?
    let results: [Place]?
    let status: String?
}

// MARK: - Place

struct Place: Identifiable, Codable, Equatable, Hashable, Comparable {
    
    let id: UUID = UUID()
    let businessStatus: String?
    let geometry: Geometry?
    let icon: String?
    let iconBackgroundColor: String?
    let iconMaskBaseURI: String?
    let name: String?
    let placeID: String?
    let plusCode: PlusCode?
    let rating: Double?
    let reference: String?
    let scope: String?
    let types: [String]?
    let userRatingsTotal: Double?
    let vicinity: String?
    let openingHours: OpeningHours?
    let photos: [Photo]?
    
    init(
        businessStatus: String? = nil,
        geometry: Geometry? = nil,
        icon: String? = nil,
        iconBackgroundColor: String? = nil,
        iconMaskBaseURI: String? = nil,
        name: String? = nil,
        placeID: String? = nil,
        plusCode: PlusCode? = nil,
        rating: Double? = nil,
        reference: String? = nil,
        scope: String? = nil,
        types: [String]? = nil,
        userRatingsTotal: Double? = nil,
        vicinity: String? = nil,
        openingHours: OpeningHours? = nil,
        photos: [Photo]? = nil
    ) {
        self.businessStatus = businessStatus
        self.geometry = geometry
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconMaskBaseURI = iconMaskBaseURI
        self.name = name
        self.placeID = placeID
        self.plusCode = plusCode
        self.rating = rating
        self.reference = reference
        self.scope = scope
        self.types = types
        self.userRatingsTotal = userRatingsTotal
        self.vicinity = vicinity
        self.openingHours = openingHours
        self.photos = photos
    }
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.placeID == rhs.placeID && lhs.id == rhs.id
    }

    static func < (lhs: Place, rhs: Place) -> Bool {
        return lhs.placeID == rhs.placeID
    }
}

// MARK: - Geometry

struct Geometry: Codable, Hashable {
    let location: Location?
    let viewport: Viewport?

    init(location: Location? = nil, viewport: Viewport? = nil) {
        self.location = location
        self.viewport = viewport
    }
}

// MARK: - Location

struct Location: Codable, Hashable {
    var lat: Double = 0
    var lng: Double = 0
}

// MARK: - Viewport

struct Viewport: Codable, Hashable {
    let northeast: Location?
    let southwest: Location?
}

// MARK: - OpeningHours

struct OpeningHours: Codable, Equatable, Hashable {
    let openNow: Bool?
}

// MARK: - Photo

struct Photo: Codable, Equatable, Hashable {
    let height: Double?
    let htmlAttributions: [String]?
    let photoReference: String?
    let width: Double?
}

// MARK: - PlusCode

struct PlusCode: Codable, Equatable, Hashable {
    let compoundCode: String?
    let globalCode: String?
}
