//
//  Optional.swift
//  Dash
//
//  Created by Steffi Tan on 2/27/22.
//

import Foundation
extension Optional where Wrapped == String {
  var isNilOrEmpty: Bool {
    let cleanedValue = self?.trimmingCharacters(in: .whitespacesAndNewlines)
    return cleanedValue?.isEmpty ?? true
  }
  
  /**
   * Returns unwrap value on completion if not nil or empy.
   * - Parameter completion: returC
   */
  func notNilOrEmpty(_ completion: @escaping (String) -> ()) {
    guard !self.isNilOrEmpty else { return }
    return completion(self.unsafelyUnwrapped)
  }
}
