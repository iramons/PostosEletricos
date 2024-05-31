//
//  Bundle+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 31/05/24.
//

import Foundation

extension Bundle {
    var appName: String {
        return (infoDictionary?["CFBundleDisplayName"] as? String) ??
               (infoDictionary?["CFBundleName"] as? String) ?? ""
    }
}
