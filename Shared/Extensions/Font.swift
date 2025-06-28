//
//  Font.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import SwiftUI

extension Font {
  // TODO: Add scaling support with min and maximum
  static func regular(size: CGFloat) -> Font {
    return Font.system(size: size, weight: .regular)
  }
  
  static func semibold(size: CGFloat) -> Font {
    return Font.system(size: size, weight: .semibold)
  }
  
  static func bold(size: CGFloat) -> Font {
    return Font.system(size: size, weight: .bold)
  }
  
  static func heavy(size: CGFloat) -> Font {
    return Font.system(size: size, weight: .heavy)
  }
}

// MARK: - View extension
extension View {
  func fontRegular(size: CGFloat) -> some View {
    self.font(.regular(size: size))
  }
  
  func fontSemibold(size: CGFloat) -> some View {
    self.font(.semibold(size: size))
  }

  func fontBold(size: CGFloat) -> some View {
    self.font(.bold(size: size))
  }
  
  func fontHeavy(size: CGFloat) -> some View {
    self.font(.heavy(size: size))
  }
}
