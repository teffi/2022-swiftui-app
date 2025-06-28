//
//  Color.swift
//  Dash
//
//  Created by Steffi Tan on 2/23/22.
//

import SwiftUI

enum AssetsColor: String {
  case purple
  case black
  case light_purple_translucent
  case purple_powder
  case gray_1
  case gray_2
  case green
  case white
  case warning
}

extension Color {
  static func assetColor(_ color: AssetsColor) -> Color {
    return Color(color.rawValue)
  }
  
  static func hex(_ code: String) -> Color {
    let hex = code.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    return Color(.sRGB, red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, opacity: CGFloat(a) / 255)
  }
}

// MARK: - View extension
extension View {
  func bgAssetColor(_ color: AssetsColor, opacity: CGFloat = 1.0) -> some View {
    background(Color.assetColor(color).opacity(opacity))
  }
  
  func fgAssetColor(_ color: AssetsColor, opacity: CGFloat = 1.0) -> some View {
    foregroundColor(Color.assetColor(color).opacity(opacity))
  }
}
