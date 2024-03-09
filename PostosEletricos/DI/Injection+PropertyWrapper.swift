//
//  Injection+PropertyWrapper.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation

@propertyWrapper
public struct Injected<T> {
    private var service: T
    
    public init() {
        self.service = DependencyContainer.resolve()
    }

    public var wrappedValue: T {
        get { return service }
        mutating set { service = newValue }
    }
}

public class DependencyContainer {
    private static var services: [String: Any] = [:]

    public static func register<T>(service: T) {
        let key = String(describing: T.self)
        services[key] = service
    }

    public static func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let service = services[key] as? T else {
            fatalError("No registered service for type \(key)")
        }
        return service
    }
}
