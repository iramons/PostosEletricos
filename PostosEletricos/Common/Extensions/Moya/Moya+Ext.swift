//
//  Moya+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 04/05/24.
//

import Foundation
import Moya

extension MoyaProvider {

    class MoyaConcurrency {
        private let provider: MoyaProvider

        init(provider: MoyaProvider) {
            self.provider = provider
        }

        func request<T: Decodable>(_ target: MoyaProvider.Target) async throws -> T {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(target) { result in
                    switch result {
                    case .success(let response):
                        do {
                            let res = try JSONDecoder.default.decode(T.self, from: response.data)
                            continuation.resume(returning: res)
                        } catch {
                            printLog(.critical, "\(error) \(error.localizedDescription)")
                            continuation.resume(throwing: MoyaError.jsonMapping(response))
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    var async: MoyaConcurrency {
        MoyaConcurrency(provider: self)
    }
}

extension JSONDecoder {

    static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }
}
