//
//  UIViewController+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 10/03/24.
//

import Foundation
import UIKit
import CoreLocation

extension UIViewController {
    public func showMapsSheet(
        coordinates: CLLocationCoordinate2D?,
        address: String,
        title: String? = nil,
        message: String? = nil,
        exceptions: [MapApps]? = nil,
        onAddressCopied: ((Bool) -> Void)? = nil,
        handler _: ((Bool) -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        
        alert.overrideUserInterfaceStyle = .light
        
        if let exceps = exceptions {
            MapApps.exceptions = exceps
        }
        
        if let coordinates = coordinates {
            for service in MapApps.availableServices {
                let action = UIAlertAction(
                    title: service.name,
                    style: .default,
                    handler: { _ in
                        service.open(
                            coordinates: coordinates,
                            address: address
                        )
                    }
                )
                alert.addAction(action)
            }
        }
        
        let copyAction = UIAlertAction(
            title: "Copiar",
            style: .default,
            handler: { [weak self] _ in
                UIPasteboard.general.string = address
                self?.dismiss(animated: true)
                onAddressCopied?(true)
            }
        )
        alert.addAction(copyAction)
        
        let cancelAction = UIAlertAction(
            title: "Cancelar",
            style: .cancel
        )
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
