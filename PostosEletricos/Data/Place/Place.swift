//
//  Place.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation
import MapKit
import GooglePlaces

// MARK: - Place

struct Place: Codable, Identifiable, Equatable, Hashable, Comparable {

    let id: String = UUID().uuidString
    var placeID: String?
    var name: String
    var vicinity: String?
    var geometry: Geometry?
    var businessStatus: String?
    var plusCode: PlusCode?
    var rating: Double?
    var reference: String?
    var scope: String?
    var types: [String]?
    var userRatingsTotal: Double?
    var openingHours: OpeningHours?
    var photos: [Photo]?

    /// Especifically from GMSPlace
    var phoneNumber: String?
    var currentOpeningHours: GMSOpeningHours?

    enum CodingKeys: String, CodingKey {
        case id
        case placeID = "place_id"
        case name
        case vicinity
        case geometry
        case businessStatus = "business_status"
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
        plusCode: PlusCode? = nil,
        rating: Double? = nil,
        reference: String? = nil,
        scope: String? = nil,
        types: [String]? = nil,
        userRatingsTotal: Double? = nil,
        openingHours: OpeningHours? = nil,
        photos: [Photo]? = nil,
        phoneNumber: String? = nil,
        currentOpeningHours: GMSOpeningHours? = nil
    ) {
        self.placeID = placeID
        self.name = name
        self.vicinity = vicinity
        self.geometry = geometry
        self.businessStatus = businessStatus
        self.plusCode = plusCode
        self.rating = rating
        self.reference = reference
        self.scope = scope
        self.types = types
        self.userRatingsTotal = userRatingsTotal
        self.openingHours = openingHours
        self.photos = photos
        self.phoneNumber = phoneNumber
        self.currentOpeningHours = currentOpeningHours
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

// MARK: - update

extension Place {

    /// Update all element, excluding ID and placeID
    mutating func update(_ place: Place) {
        self.name = place.name
        if let vicinity = place.vicinity { self.vicinity = vicinity }
        if let geometry = place.geometry { self.geometry = geometry }
        if let businessStatus = place.businessStatus { self.businessStatus = businessStatus }
        if let plusCode = place.plusCode { self.plusCode = plusCode }
        if let rating = place.rating { self.rating = rating }
        if let reference = place.reference { self.reference = reference }
        if let scope = place.scope { self.scope = scope }
        if let types = place.types { self.types = types }
        if let userRatingsTotal = place.userRatingsTotal { self.userRatingsTotal = userRatingsTotal }
        if let openingHours = place.openingHours { self.openingHours = openingHours }
        if let photos = place.photos { self.photos = photos }
        if let phoneNumber = place.phoneNumber { self.phoneNumber = phoneNumber }
        if let currentOpeningHours = place.currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
    }

    /// Update espefic attributes, excluding ID and placeID
    mutating func update(
        name: String? = nil,
        vicinity: String? = nil,
        geometry: Geometry? = nil,
        businessStatus: String? = nil,
        plusCode: PlusCode? = nil,
        rating: Double? = nil,
        reference: String? = nil,
        scope: String? = nil,
        types: [String]? = nil,
        userRatingsTotal: Double? = nil,
        openingHours: OpeningHours? = nil,
        photos: [Photo]? = nil,
        phoneNumber: String? = nil
    ) {
        if let name { self.name = name }
        if let vicinity { self.vicinity = vicinity }
        if let geometry { self.geometry = geometry }
        if let businessStatus { self.businessStatus = businessStatus }
        if let plusCode { self.plusCode = plusCode }
        if let rating { self.rating = rating }
        if let reference { self.reference = reference }
        if let scope { self.scope = scope }
        if let types { self.types = types }
        if let userRatingsTotal { self.userRatingsTotal = userRatingsTotal }
        if let openingHours { self.openingHours = openingHours }
        if let photos { self.photos = photos }
        if let phoneNumber { self.phoneNumber = phoneNumber }
        if let currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
    }
}