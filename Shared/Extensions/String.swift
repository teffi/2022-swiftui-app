//
//  String.swift
//  Dash
//
//  Created by Steffi Tan on 2/27/22.
//

import Foundation

//  Extend String to make it identifiable so we can directly use String in SwiftUI's ForEach loops.
//  use case: Doing foreach over an array of imageurls which could potentially have multiple empty index value.
extension String: Identifiable {
  public typealias ID = Int
  public var id: Int {
    //  Use UUID if empty.
    if isEmpty {
      return UUID().hashValue
    }
    return hashValue
  }
}

//  URL query related
extension String {
  /// addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) encode parameters following RFC 3986
  /// which we need to encode other special characters correctly.
  /// We then also encode "+" sign with its HTTP equivalent
  var percentEncoded: String? {
    self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
      .replacingOccurrences(of: "+", with: "%2B")
  }
}
