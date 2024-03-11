//
//  URL+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import UIKit

public extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }

    var sanitize: URL {
        if var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if components.scheme == nil {
                components.scheme = "http"
            }
            return components.url ?? self
        }
        return self
    }

    var canOpenURL: Bool {
        return UIApplication.shared.canOpenURL(self)
    }

    func openURL() {
        UIApplication.shared.open(self)
    }
}
