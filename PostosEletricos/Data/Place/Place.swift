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
    var addressComponents: [AddressComponent]?
    var businessStatus: String?// BusinessStatus?
    var displayName: DisplayName?
    var evChargeOptions: EvChargeOptions?
    var formattedAddress: String?
    var googleMapsURI: String?
    var iconMaskBaseURI: String?
    var location: Location?
    var plusCode: PlusCode?
    var primaryType: String?
    var primaryTypeDisplayName: DisplayName?
    var shortFormattedAddress: String?
    var types: [String]?
    var utcOffsetMinutes: Int?
    var viewport: Viewport?
    var website: String?
    var currentOpeningHours, regularOpeningHours: OpeningHours?
    var internationalPhoneNumber, nationalPhoneNumber: String?
    var photos: [Photo]?

    enum CodingKeys: String, CodingKey {
        case addressComponents, businessStatus, displayName, evChargeOptions, formattedAddress
        case googleMapsURI = "googleMapsUri"
        case iconMaskBaseURI = "iconMaskBaseUri"
        case placeID = "id"
        case location, plusCode, primaryType, primaryTypeDisplayName, shortFormattedAddress, types, utcOffsetMinutes, viewport
        case website = "websiteUri"
        case nationalPhoneNumber, internationalPhoneNumber
        case currentOpeningHours, regularOpeningHours, photos
    }

    init(
        placeID: String? = nil,
        addressComponents: [AddressComponent]? = nil,
        businessStatus: String? = nil,
        displayName: DisplayName? = nil,
        evChargeOptions: EvChargeOptions? = nil,
        formattedAddress: String? = nil,
        googleMapsURI: String? = nil,
        iconMaskBaseURI: String? = nil,
        location: Location? = nil,
        plusCode: PlusCode? = nil,
        primaryType: String? = nil,
        primaryTypeDisplayName: DisplayName? = nil,
        shortFormattedAddress: String? = nil,
        types: [String]? = nil,
        utcOffsetMinutes: Int? = nil,
        viewport: Viewport? = nil,
        currentOpeningHours: OpeningHours? = nil,
        regularOpeningHours: OpeningHours? = nil,
        nationalPhoneNumber: String? = nil,
        internationalPhoneNumber: String? = nil,
        photos: [Photo]? = nil,
        website: String? = nil
    ) {
            self.placeID = placeID
            self.addressComponents = addressComponents
            self.businessStatus = businessStatus
            self.displayName = displayName
            self.evChargeOptions = evChargeOptions
            self.formattedAddress = formattedAddress
            self.googleMapsURI = googleMapsURI
            self.iconMaskBaseURI = iconMaskBaseURI
            self.location = location
            self.plusCode = plusCode
            self.primaryType = primaryType
            self.primaryTypeDisplayName = primaryTypeDisplayName
            self.shortFormattedAddress = shortFormattedAddress
            self.types = types
            self.utcOffsetMinutes = utcOffsetMinutes
            self.viewport = viewport
            self.currentOpeningHours = currentOpeningHours
            self.regularOpeningHours = regularOpeningHours
            self.nationalPhoneNumber = nationalPhoneNumber
            self.internationalPhoneNumber = internationalPhoneNumber
            self.photos = photos
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

    var name: String { displayName?.text ?? "Posto Elétrico" }

    /// Return nationalPhoneNumber if exists, else return internationalPhoneNumber else return nil
    var phoneNumber: String? { nationalPhoneNumber ?? internationalPhoneNumber }

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
        if let formattedAddress = place.formattedAddress { self.formattedAddress = formattedAddress }
        if let location = place.location { self.location = location }
        if let businessStatus = place.businessStatus { self.businessStatus = businessStatus }
        if let plusCode = place.plusCode { self.plusCode = plusCode }
        if let types = place.types { self.types = types }
        if let regularOpeningHours = place.regularOpeningHours { self.regularOpeningHours = regularOpeningHours }
        if let currentOpeningHours = place.currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
        if let photos = place.photos { self.photos = photos }
        if let nationalPhoneNumber = place.nationalPhoneNumber { self.nationalPhoneNumber = nationalPhoneNumber }
        if let internationalPhoneNumber = place.internationalPhoneNumber { self.internationalPhoneNumber = internationalPhoneNumber }
        if let website = place.website { self.website = website }
    }

    /// Update espefic attributes, excluding ID and placeID
    mutating func update(
        location: Location? = nil,
        businessStatus: String? = nil,
        plusCode: PlusCode? = nil,
        types: [String]? = nil,
        regularOpeningHours: OpeningHours? = nil,
        currentOpeningHours: OpeningHours? = nil,
        photos: [Photo]? = nil,
        nationalPhoneNumber: String? = nil,
        internationalPhoneNumber: String? = nil,
        website: String? = nil
    ) {
        if let formattedAddress { self.formattedAddress = formattedAddress }
        if let location { self.location = location }
        if let businessStatus { self.businessStatus = businessStatus }
        if let plusCode { self.plusCode = plusCode }
        if let types { self.types = types }
        if let regularOpeningHours { self.regularOpeningHours = regularOpeningHours }
        if let currentOpeningHours { self.currentOpeningHours = currentOpeningHours }
        if let photos { self.photos = photos }
        if let nationalPhoneNumber { self.nationalPhoneNumber = nationalPhoneNumber }
        if let internationalPhoneNumber { self.internationalPhoneNumber = internationalPhoneNumber }
        if let website { self.website = website }
    }
}
