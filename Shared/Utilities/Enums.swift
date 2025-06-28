//
//  Enums.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation

typealias Sentiment = Enums.Sentiment
typealias Tab = Enums.Tab

struct Enums {
  //  MARK: - Sentiment
  enum Sentiment: String {
    case love
    case hate
    
    var iconName: String {
      switch self {
      case .love:
        return "ic_love"
      case .hate:
        return "ic_hate"
      }
    }
    
    func toggle() -> Sentiment {
      switch self {
      case .love:
        return .hate
      case .hate:
        return .love
      }
    }
    
    static func parse(_ value: String) -> Sentiment? {
      return Sentiment(rawValue: value)
    }
  }
  
  //  MARK: - Tab
  enum Tab {
    case home
    case search
    case user
  }
}
