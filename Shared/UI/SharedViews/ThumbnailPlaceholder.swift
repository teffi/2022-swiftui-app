//
//  ThumbnailPlaceholder.swift
//  Dash
//
//  Created by Steffi Tan on 2/21/22.
//

import SwiftUI

struct ThumbnailPlaceholder : View {
  var cornerRadius: CGFloat = 8
  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      .fillAndClipToParent()
      .foregroundColor(Color(.secondarySystemBackground))
  }
}
