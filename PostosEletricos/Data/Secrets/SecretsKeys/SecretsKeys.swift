//
//  SecretsKeys.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 25/01/24.
//

import Foundation

enum SecretsKeys: String {
    case googlePlaces = "GooglePlacesAPIKey"

    /// `key`
    /// Fetch especific APIKey in Secrets.plist file
    /// - Returns:key if exist, else return empty string.
    var key: String {
        guard let apiKey = SecretsManager.shared.getSecret(key: self.rawValue) else {
            printLog(.critical, "Unable to retrieve the API Key for \(self.rawValue)")
            return ""
        }

        return apiKey
    }
}
