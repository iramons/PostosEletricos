//
//  Place.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation
import MapKit

// MARK: - Place

struct Place: Codable, Identifiable, Equatable, Comparable {
    let id: String = UUID().uuidString
    var placeID: String?
    var name: String = "Postos Elétricos"
    var addressComponents: [AddressComponent]?
    var businessStatus: String?// BusinessStatus?
    var displayName: DisplayName?
    var evChargeOptions: EvChargeOptions?
    var formattedAddress: String?
    var googleMapsURI: String?
    var iconBackgroundColor: IconBackgroundColor?
    var iconMaskBaseURI: String?
    var location: Location?
    var plusCode: PlusCode?
    var primaryType: String?
    var primaryTypeDisplayName: DisplayName?
    var shortFormattedAddress: String?
    var types: [String]?
    var utcOffsetMinutes: Int?
    var viewport: Viewport?
    var websiteURI: String?
    var currentOpeningHours, regularOpeningHours: OpeningHours?
    var internationalPhoneNumber, nationalPhoneNumber: String?
    var photos: [Photo]?
    var phoneNumber: String?
    var website: String?

    enum CodingKeys: String, CodingKey {
        case addressComponents, businessStatus, displayName, evChargeOptions, formattedAddress
        case googleMapsURI = "googleMapsUri"
        case iconBackgroundColor
        case iconMaskBaseURI = "iconMaskBaseUri"
        case placeID = "id"
        case location, name, plusCode, primaryType, primaryTypeDisplayName, shortFormattedAddress, types, utcOffsetMinutes, viewport
        case websiteURI = "websiteUri"
        case currentOpeningHours, regularOpeningHours, internationalPhoneNumber, nationalPhoneNumber, photos
    }

    init(
        placeID: String? = nil,
        name: String = "Postos Elétricos",
        addressComponents: [AddressComponent]? = nil,
        businessStatus: String? = nil,
        displayName: DisplayName? = nil,
        evChargeOptions: EvChargeOptions? = nil,
        formattedAddress: String? = nil,
        googleMapsURI: String? = nil,
        iconBackgroundColor: IconBackgroundColor? = nil,
        iconMaskBaseURI: String? = nil,
        location: Location? = nil,
        plusCode: PlusCode? = nil,
        primaryType: String? = nil,
        primaryTypeDisplayName: DisplayName? = nil,
        shortFormattedAddress: String? = nil,
        types: [String]? = nil,
        utcOffsetMinutes: Int? = nil,
        viewport: Viewport? = nil,
        websiteURI: String? = nil,
        currentOpeningHours: OpeningHours? = nil,
        regularOpeningHours: OpeningHours? = nil,
        internationalPhoneNumber: String? = nil,
        nationalPhoneNumber: String? = nil,
        photos: [Photo]? = nil,
        phoneNumber: String? = nil,
        website: String? = nil
    ) {
            self.placeID = placeID
            self.addressComponents = addressComponents
            self.businessStatus = businessStatus
            self.displayName = displayName
            self.evChargeOptions = evChargeOptions
            self.formattedAddress = formattedAddress
            self.googleMapsURI = googleMapsURI
            self.iconBackgroundColor = iconBackgroundColor
            self.iconMaskBaseURI = iconMaskBaseURI
            self.location = location
            self.name = name
            self.plusCode = plusCode
            self.primaryType = primaryType
            self.primaryTypeDisplayName = primaryTypeDisplayName
            self.shortFormattedAddress = shortFormattedAddress
            self.types = types
            self.utcOffsetMinutes = utcOffsetMinutes
            self.viewport = viewport
            self.websiteURI = websiteURI
            self.currentOpeningHours = currentOpeningHours
            self.regularOpeningHours = regularOpeningHours
            self.internationalPhoneNumber = internationalPhoneNumber
            self.nationalPhoneNumber = nationalPhoneNumber
            self.photos = photos
            self.phoneNumber = phoneNumber
            self.website = website
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
        guard let location,
              let latitude = location.latitude,
              let longitude = location.longitude
        else { return nil }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Returns formattedAddress if exists else return vicinity else return nil
    var fullAddress: String? { shortFormattedAddress ?? formattedAddress }

    var opened: Bool { currentOpeningHours?.openNow ?? false }
}

// MARK: - update

extension Place {

    /// Update all element, excluding ID and placeID
    mutating func update(_ place: Place) {
        self.name = place.name
        if let formattedAddress = place.formattedAddress { self.formattedAddress = formattedAddress }
        if let location = place.location { self.location = location }
        if let businessStatus = place.businessStatus { self.businessStatus = businessStatus }
        if let plusCode = place.plusCode { self.plusCode = plusCode }
        if let types = place.types { self.types = types }
        if let regularOpeningHours = place.regularOpeningHours { self.regularOpeningHours = regularOpeningHours }
        if let currentOpeningHours = place.currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
        if let photos = place.photos { self.photos = photos }
        if let phoneNumber = place.phoneNumber { self.phoneNumber = phoneNumber }
        if let website = place.website { self.website = website }
    }

    /// Update espefic attributes, excluding ID and placeID
    mutating func update(
        name: String? = nil,
        location: Location? = nil,
        businessStatus: String? = nil,
        plusCode: PlusCode? = nil,
        types: [String]? = nil,
        regularOpeningHours: OpeningHours? = nil,
        currentOpeningHours: OpeningHours? = nil,
        photos: [Photo]? = nil,
        phoneNumber: String? = nil,
        website: String? = nil
    ) {
        if let name { self.name = name }
        if let formattedAddress { self.formattedAddress = formattedAddress }
        if let location { self.location = location }
        if let businessStatus { self.businessStatus = businessStatus }
        if let plusCode { self.plusCode = plusCode }
        if let types { self.types = types }
        if let regularOpeningHours { self.regularOpeningHours = regularOpeningHours }
        if let currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
        if let photos { self.photos = photos }
        if let phoneNumber { self.phoneNumber = phoneNumber }
        if let website { self.website = website }
    }
}



//// MARK: - Place
//
//struct Place: Codable, Identifiable, Equatable, Hashable, Comparable {
//
//    let id: String = UUID().uuidString
//    var placeID: String?
//    var name: String
//    var vicinity: String?
//    var formattedAddress: String?
//    var geometry: Geometry?
//    var businessStatus: String?
//    var plusCode: PlusCode?
//    var rating: Double?
//    var reference: String?
//    var scope: String?
//    var types: [String]?
//    var userRatingsTotal: Double?
//    var openingHours: OpeningHours?
//    var currentOpeningHours: OpeningHours?
//    var photos: [Photo]?
//    var phoneNumber: String?
//    var website: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case placeID = "place_id"
//        case name
//        case vicinity
//        case formattedAddress = "formatted_address"
//        case geometry
//        case businessStatus = "business_status"
//        case plusCode = "plus_code"
//        case rating
//        case reference
//        case scope
//        case types
//        case userRatingsTotal = "user_ratings_total"
//        case openingHours = "opening_hours"
//        case currentOpeningHours = "current_opening_hours"
//        case photos
//        case phoneNumber = "formatted_phone_number"
//        case website
//    }
//
//    init(
//        placeID: String? = nil,
//        name: String = "Posto Elétrico",
//        vicinity: String? = nil,
//        formattedAddress: String? = nil,
//        geometry: Geometry? = nil,
//        businessStatus: String? = nil,
//        plusCode: PlusCode? = nil,
//        rating: Double? = nil,
//        reference: String? = nil,
//        scope: String? = nil,
//        types: [String]? = nil,
//        userRatingsTotal: Double? = nil,
//        openingHours: OpeningHours? = nil,
//        currentOpeningHours: OpeningHours? = nil,
//        photos: [Photo]? = nil,
//        phoneNumber: String? = nil,
//        website: String? = nil
//    ) {
//        self.placeID = placeID
//        self.name = name
//        self.vicinity = vicinity
//        self.formattedAddress = formattedAddress
//        self.geometry = geometry
//        self.businessStatus = businessStatus
//        self.plusCode = plusCode
//        self.rating = rating
//        self.reference = reference
//        self.scope = scope
//        self.types = types
//        self.userRatingsTotal = userRatingsTotal
//        self.openingHours = openingHours
//        self.currentOpeningHours = currentOpeningHours
//        self.photos = photos
//        self.phoneNumber = phoneNumber
//        self.website = website
//    }
//
//    static func == (lhs: Place, rhs: Place) -> Bool {
//        lhs.placeID == rhs.placeID && lhs.id == rhs.id
//    }
//
//    static func < (lhs: Place, rhs: Place) -> Bool {
//        return lhs.placeID == rhs.placeID
//    }
//}
//
//extension Place {
//
//    /// Return coordinate base on Geometry and Location results
//    var coordinate: CLLocationCoordinate2D? {
//        guard let geometry, let location = geometry.location else { return nil }
//        return CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
//    }
//
//    /// Returns formattedAddress if exists else return vicinity else return nil
//    var fullAddress: String? { formattedAddress ?? vicinity }
//
//    var opened: Bool { currentOpeningHours?.openNow ?? openingHours?.openNow ?? false }
//}
//
//// MARK: - update
//
//extension Place {
//
//    /// Update all element, excluding ID and placeID
//    mutating func update(_ place: Place) {
//        self.name = place.name
//        if let formattedAddress = place.formattedAddress { self.formattedAddress = formattedAddress }
//        if let geometry = place.geometry { self.geometry = geometry }
//        if let businessStatus = place.businessStatus { self.businessStatus = businessStatus }
//        if let plusCode = place.plusCode { self.plusCode = plusCode }
//        if let rating = place.rating { self.rating = rating }
//        if let reference = place.reference { self.reference = reference }
//        if let scope = place.scope { self.scope = scope }
//        if let types = place.types { self.types = types }
//        if let userRatingsTotal = place.userRatingsTotal { self.userRatingsTotal = userRatingsTotal }
//        if let openingHours = place.openingHours { self.openingHours = openingHours }
//        if let currentOpeningHours = place.currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
//        if let photos = place.photos { self.photos = photos }
//        if let phoneNumber = place.phoneNumber { self.phoneNumber = phoneNumber }
//        if let website = place.website { self.website = website }
//    }
//
//    /// Update espefic attributes, excluding ID and placeID
//    mutating func update(
//        name: String? = nil,
//        vicinity: String? = nil,
//        geometry: Geometry? = nil,
//        businessStatus: String? = nil,
//        plusCode: PlusCode? = nil,
//        rating: Double? = nil,
//        reference: String? = nil,
//        scope: String? = nil,
//        types: [String]? = nil,
//        userRatingsTotal: Double? = nil,
//        openingHours: OpeningHours? = nil,
//        currentOpeningHours: OpeningHours? = nil,
//        photos: [Photo]? = nil,
//        phoneNumber: String? = nil,
//        website: String? = nil
//    ) {
//        if let name { self.name = name }
//        if let vicinity { self.vicinity = vicinity }
//        if let formattedAddress { self.formattedAddress = formattedAddress }
//        if let geometry { self.geometry = geometry }
//        if let businessStatus { self.businessStatus = businessStatus }
//        if let plusCode { self.plusCode = plusCode }
//        if let rating { self.rating = rating }
//        if let reference { self.reference = reference }
//        if let scope { self.scope = scope }
//        if let types { self.types = types }
//        if let userRatingsTotal { self.userRatingsTotal = userRatingsTotal }
//        if let openingHours { self.openingHours = openingHours }
//        if let currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
//        if let photos { self.photos = photos }
//        if let phoneNumber { self.phoneNumber = phoneNumber }
//        if let website { self.website = website }
//    }
//}
