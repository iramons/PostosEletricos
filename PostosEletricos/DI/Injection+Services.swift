//
//  Injection+Services.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation

func registerAllServices() {
    DependencyContainer.register(service: LocationService())
}
