//
//  Binding.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI

extension Binding {
  // TODO: Investigate when used in SearchBar. onChange is called twice.
  func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        handler(newValue)
      }
    )
  }
}
