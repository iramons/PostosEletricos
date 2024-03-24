//
//  UIDevice+Ext.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 23/03/24.
//

import Foundation
import UIKit
import SwiftUI

extension UIDevice {
  static let deviceDidShake = Notification.Name(rawValue: "deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with: UIEvent?) {
        guard motion == .motionShake else { return }

    NotificationCenter.default.post(name: UIDevice.deviceDidShake, object: nil)
  }
}

struct ShakeGestureViewModifier: ViewModifier {
  let action: () -> Void

  func body(content: Content) -> some View {
    content
      .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShake)) { _ in
        action()
      }
  }
}

extension View {
    func onShakeGesture(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeGestureViewModifier(action: action))
    }
}
