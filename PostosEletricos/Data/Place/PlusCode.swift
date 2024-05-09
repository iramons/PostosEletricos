//
//  PlusCode.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - PlusCode

struct PlusCode: Codable, Equatable, Hashable {
    
    let compoundCode: String?
    let globalCode: String?

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}
