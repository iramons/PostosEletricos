//
//  LogHandler.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import Logging
import PulseLogHandler

public enum LogHandler {
    public static let logger: Logger = {
        let bundleName = Bundle.main.bundleIdentifier!

        #if DEBUG
        return Logger(label: bundleName, factory: { name, provider in
            PersistentLogHandler(label: name, metadataProvider: provider)
        })
        #else
        return Logger(label: bundleName)
        #endif
    }()
}
