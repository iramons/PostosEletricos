//
//  FetchState.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 22/03/24.
//

import Foundation


// MARK: FetchState

/// `FetchState`
///  Default global state to use for fetching request and get states.
enum FetchState: Equatable {
    case isLoading(Bool)
    case `none`
}
