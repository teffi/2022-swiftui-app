//
//  LoveImage.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct LoveImage: View {
  var body: some View {
    Image(Sentiment.love.iconName)
      .icon()
  }
}

struct LoveImage_Previews: PreviewProvider {
  static var previews: some View {
    LoveImage()
  }
}

