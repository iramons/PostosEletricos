//
//  SecretsKeys.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 25/01/24.
//

import Foundation

enum SecretsKeys: String {
    case googlePlacesAPIKeyRelease
    case googleADSUnitIDDebug
    case googleADSUnitIDRelease

    /// `key`
    /// Fetch especific APIKey in Secrets.plist file
    /// - Returns:key if exist, else return empty string.
    var key: String {
        guard let apiKey = SecretsManager.shared.getSecret(key: rawValue) else {
            printLog(.critical, "Unable to retrieve the Key for \(rawValue)")
            return ""
        }

        return apiKey
    }
}

// MARK: Google

extension SecretsKeys {
    static var googlePlacesKey: String {
        return SecretsKeys.googlePlacesAPIKeyRelease.key
    }
    
    static var googleADSKey: String {
        #if DEBUG
        return SecretsKeys.googleADSUnitIDDebug.key
        #else
        return SecretsKeys.googleADSUnitIDRelease.key
        #endif
    }
}
