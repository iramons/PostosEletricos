//
//  Geometry.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - Geometry

struct Geometry: Codable, Hashable {
    
    let location: Location?
    let viewport: Viewport?

    init(location: Location? = nil, viewport: Viewport? = nil) {
        self.location = location
        self.viewport = viewport
    }
}
