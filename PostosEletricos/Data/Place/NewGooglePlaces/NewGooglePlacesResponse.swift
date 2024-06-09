//
//  NewGooglePlacesResponse.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 03/06/24.
//

import Foundation
import MapKit


// MARK: - ContextualContent
struct ContextualContent: Codable {
    let photos: [Photo]?
}

// MARK: - AuthorAttribution
struct AuthorAttribution: Codable {
    let displayName, photoURI, uri: String?

    enum CodingKeys: String, CodingKey {
        case displayName
        case photoURI = "photoUri"
        case uri
    }
}

// MARK: - AddressComponent
struct AddressComponent: Codable {
    let languageCode: String? //LanguageCodeEnum
    let longText, shortText: String?
    let types: [String]?
}

#warning("check to remove")
enum TypeElement: String, Codable {
    case administrativeAreaLevel1 = "administrative_area_level_1"
    case administrativeAreaLevel2 = "administrative_area_level_2"
    case country = "country"
    case establishment = "establishment"
    case pointOfInterest = "point_of_interest"
    case political = "political"
    case postalCode = "postal_code"
    case route = "route"
    case streetNumber = "street_number"
    case sublocality = "sublocality"
    case sublocalityLevel1 = "sublocality_level_1"
}

enum BusinessStatus: String, Codable {
    case operational = "OPERATIONAL"
}

// MARK: - DisplayName
struct DisplayName: Codable {
    let languageCode: String? // LanguageCodeEnum
    let text: String?
}

// MARK: - EvChargeOptions
struct EvChargeOptions: Codable {
    let connectorAggregation: [ConnectorAggregation]?
    let connectorCount: Int?
}

// MARK: - ConnectorAggregation
struct ConnectorAggregation: Codable {
    let availabilityLastUpdateTime: String?
    let availableCount, count: Int?
    let maxChargeRateKw: Double?
    let outOfServiceCount: Int?
    let type: String? // ConnectorAggregationType
}

enum ConnectorAggregationType: String, Codable {
    case ccsCombo2 = "EV_CONNECTOR_TYPE_CCS_COMBO_2"
    case type2 = "EV_CONNECTOR_TYPE_TYPE_2"
    case j1772 = "EV_CONNECTOR_TYPE_J1772"
}

enum IconBackgroundColor: String, Codable {
    case the7B9Eb0 = "#7B9EB0"
}


// MARK: - PlusCode
struct NewPlusCode: Codable {
    let compoundCode, globalCode: String?
}

enum PrimaryTypeEnum: String, Codable {
    case electricVehicleChargingStation = "electric_vehicle_charging_station"
    case establishment = "establishment"
    case pointOfInterest = "point_of_interest"
    case `default`
}

