//
//  Array.swift
//  Dash
//
//  Created by Steffi Tan on 3/17/22.
//

import Foundation

extension Array {
  // Safely check index range and returns the element
  subscript(safe index: Index) -> Iterator.Element? {
    if self.endIndex > index && self.startIndex <= index {
      return self[index]
    }
    return nil
    }
}
