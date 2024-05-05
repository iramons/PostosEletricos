//
//  GooglePlaces.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 26/01/24.
//

import Foundation
import MapKit

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

// MARK: - Place

struct Place: Codable, Identifiable, Equatable, Hashable, Comparable {
    
    let id: String = UUID().uuidString
    let placeID: String?
    let name: String
    let vicinity: String?
    let geometry: Geometry?
    let businessStatus: String?
    let icon: String?
    let iconBackgroundColor: String?
    let iconMaskBaseURI: String?
    let plusCode: PlusCode?
    let rating: Double?
    let reference: String?
    let scope: String?
    let types: [String]?
    let userRatingsTotal: Double?
    let openingHours: OpeningHours?
    let photos: [Photo]?

    enum CodingKeys: String, CodingKey {
        case id
        case placeID = "place_id"
        case name
        case vicinity
        case geometry
        case businessStatus = "business_status"
        case icon
        case iconBackgroundColor = "icon_background_color"
        case iconMaskBaseURI = "icon_mask_base_uri"
        case plusCode = "plus_code"
        case rating
        case reference
        case scope
        case types
        case userRatingsTotal = "user_ratings_total"
        case openingHours = "opening_hours"
        case photos
    }

    init(
        placeID: String? = nil,
        name: String = "Posto Elétrico",
        vicinity: String? = nil,
        geometry: Geometry? = nil,
        businessStatus: String? = nil,
        icon: String? = nil,
        iconBackgroundColor: String? = nil,
        iconMaskBaseURI: String? = nil,
        plusCode: PlusCode? = nil,
        rating: Double? = nil,
        reference: String? = nil,
        scope: String? = nil,
        types: [String]? = nil,
        userRatingsTotal: Double? = nil,
        openingHours: OpeningHours? = nil,
        photos: [Photo]? = nil
    ) {
        self.placeID = placeID
        self.name = name
        self.vicinity = vicinity
        self.geometry = geometry
        self.businessStatus = businessStatus
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconMaskBaseURI = iconMaskBaseURI
        self.plusCode = plusCode
        self.rating = rating
        self.reference = reference
        self.scope = scope
        self.types = types
        self.userRatingsTotal = userRatingsTotal
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

extension Place {

    /// Return coordinate base on Geometry and Location results
    var coordinate: CLLocationCoordinate2D? {
        guard let geometry, let location = geometry.location else { return nil }
        return CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
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

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

// MARK: - Photo

struct Photo: Codable, Equatable, Hashable {
    let height: Double?
    let htmlAttributions: [String]?
    let photoReference: String?
    let width: Double?

    enum CodingKeys: String, CodingKey {
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
}

// MARK: - PlusCode

struct PlusCode: Codable, Equatable, Hashable {
    let compoundCode: String?
    let globalCode: String?

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}
