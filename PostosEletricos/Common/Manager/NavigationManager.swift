//
//  NavigationManager.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 31/05/24.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var currentView: CurrentView = .launch

    enum CurrentView {
        case launch
        case map
    }
}
