//
//  UIApplication.swift
//  Dash
//
//  Created by Steffi Tan on 3/1/22.
//

import UIKit
import SwiftUI

extension UIApplication {
  var keyWindow: UIWindow? {
    connectedScenes
      .compactMap {
        $0 as? UIWindowScene
      }
      .flatMap {
        $0.windows
      }
      .first {
        $0.isKeyWindow
      }
  }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
  static var defaultValue: EdgeInsets {
    UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
  }
}

extension EnvironmentValues {
  var safeAreaInsets: EdgeInsets {
    self[SafeAreaInsetsKey.self]
  }
}

private extension UIEdgeInsets {
  var swiftUiInsets: EdgeInsets {
    EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
  }
}
