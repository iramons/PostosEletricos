//
//  Logging+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import Logging
import OSLog

// MARK: Logging.Logger.Level

public extension Logging.Logger.Level {

    /// Converts `Level` to `OSLogType`.
    ///
    /// This method maps each case of `Level` to a corresponding `OSLogType`. Since `OSLogType` does not have
    /// specific levels for every case of `Level` (like `trace` or `notice`), some cases are grouped together
    /// and mapped to the closest matching `OSLogType`.
    ///
    /// - Returns: An `OSLogType` value that corresponds to the `Level`.
    func toOSLogType() -> OSLogType {
        switch self {
        case .debug, .trace:
            return .debug
        case .info, .notice:
            return .info
        case .error, .warning:
            return .error
        case .critical:
            return .fault
        }
    }
}
