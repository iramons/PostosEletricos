//
//  Injection+Services.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    
    /// Called internally by Resolver library
    public static func registerAllServices() {
        Resolver.register { LocationService() }.scope(.application)
    }
}
