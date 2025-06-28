//
//  URLQueryItem.swift
//  Dash
//
//  Created by Steffi Tan on 2/27/22.
//

import Foundation

extension URLQueryItem {
  func percentEncoded() -> URLQueryItem {
    /// addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) encode parameters following RFC 3986
    /// which we need to encode other special characters correctly.
    /// We then also encode "+" sign with its HTTP equivalent
    var newQueryItem = self
    newQueryItem.value = value?.percentEncoded
    return newQueryItem
  }
}

extension Array where Element == URLQueryItem {
  func percentEncoded() -> Array<Element> {
    return map { $0.percentEncoded() }
  }
}
