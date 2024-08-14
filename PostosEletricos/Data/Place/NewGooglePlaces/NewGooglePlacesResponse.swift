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
    let availableCount: Int?
    let count: Int?
    let maxChargeRateKw: Double?
    let outOfServiceCount: Int?
    let type: ConnectorAggregationType?
}

enum ConnectorAggregationType: String, Codable {
    /// Unspecified connector
    case unspecified = "EV_CONNECTOR_TYPE_UNSPECIFIED"

    /// Other connector types
    case other = "EV_CONNECTOR_TYPE_OTHER"

    /// J1772 type 1 connector
    case j1772 = "EV_CONNECTOR_TYPE_J1772"

    /// IEC 62196 type 2 connector. Often referred to as MENNEKES.
    case type2 = "EV_CONNECTOR_TYPE_TYPE_2"

    /// CHAdeMO type connector.
    case chadeMO = "EV_CONNECTOR_TYPE_CHADEMO"

    /// Combined Charging System (AC and DC). Based on SAE. Type-1 J-1772 connector
    case ccsCombo1 = "EV_CONNECTOR_TYPE_CCS_COMBO_1"

    /// Combined Charging System (AC and DC). Based on Type-2 Mennekes connector
    case ccsCombo2 = "EV_CONNECTOR_TYPE_CCS_COMBO_2"

    /// The generic TESLA connector. This is NACS in the North America but can be non-NACS in other parts of the world (e.g. CCS Combo 2 (CCS2) or GB/T). This value is less representative of an actual connector type, and more represents the ability to charge a Tesla brand vehicle at a Tesla owned charging station.
    case tesla = "EV_CONNECTOR_TYPE_TESLA"

    /// GB/T type corresponds to the GB/T standard in China. This type covers all GB_T types.
    case unspecifiedGBT = "EV_CONNECTOR_TYPE_UNSPECIFIED_GB_T"

    /// Unspecified wall outlet.
    case unspecifiedWallOutlet = "EV_CONNECTOR_TYPE_UNSPECIFIED_WALL_OUTLET"
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

