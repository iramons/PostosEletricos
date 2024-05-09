//
//  FetchState.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 22/03/24.
//

import Foundation

/// `FetchState`
///  Default global state to use for fetching request and get states.
enum FetchState<T> {
    case isLoading(Bool)
    case success(T)
    case failure(Error)
    case `none`
}
