//
//  LoadingState.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 11/04/24.
//

import Foundation

enum LoadingState {
    case idle
    case loading
    case success(Data)
    case failed(Error)
}
