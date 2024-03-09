//
//  Config.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 25/01/24.
//

import Foundation
import Moya

struct NetworkConfig {
    static var loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
    static var networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
}
