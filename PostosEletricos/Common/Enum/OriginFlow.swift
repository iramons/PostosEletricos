//
//  OriginFlow.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 18/05/24.
//

import Foundation

// MARK: OriginFlow

/// Global enum used to determine of whatever origin the View is called.
enum OriginFlow {
    case `none`
    case appInitialization
    case launch
    case map
}
