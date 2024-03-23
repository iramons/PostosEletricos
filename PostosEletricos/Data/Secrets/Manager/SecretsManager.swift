//
//  SecretsManager.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation

final class SecretsManager {
    static let shared = SecretsManager()
    private var secrets: NSDictionary?

    private init() {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) {
            secrets = dict
        }
    }

    func getSecret(key: String) -> String? {
        secrets?.object(forKey: key) as? String
    }
}
