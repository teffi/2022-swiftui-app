//
//  ProductEnv.swift
//  Dash
//
//  Created by Steffi Tan on 2/10/22.
//

import Foundation
import SwiftUI

/// Environment object use for product -> review workflow
class ProductEnv: ObservableObject {
  @Published var product: Product?
  @Published var shouldRefreshData = false
  
  /// Calling this will set refresh bool flag to true/
  func invalidateData() {
    shouldRefreshData = true
  }
}
