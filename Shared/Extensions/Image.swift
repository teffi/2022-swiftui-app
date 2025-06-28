//
//  Image.swift
//  Dash
//
//  Created by Steffi Tan on 2/10/22.
//

import SwiftUI

extension Image {
  /// Adapts to parent frame while keeping a 1:1 aspect ratio. Usually used for images in grid stack
  /// - Important: To get a square, parent should be square.
  /// https://stackoverflow.com/a/64252041/1045672
  /// - Returns:
  func autoResizeProductThumbnail() -> some View {
    self
      .renderingMode(.original)
      .resizable()
      .scaledToFill()
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fill)
      .clipped()
  }
  
  func scaleFill() -> some View {
    self
      .renderingMode(.original)
      .resizable()
      .scaledToFill()
  }
  
  func thumbnail() -> some View {
    self
      .scaleFill()
      .fillAndClipToParent()
  }
  
  /// Apply common modifiers for icon images.
  /// - Returns:
  func icon() -> some View {
    self
      .resizable()
      .renderingMode(.original)
      .scaledToFit()
  }
}
