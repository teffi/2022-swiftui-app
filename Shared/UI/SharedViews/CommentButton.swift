//
//  CommentButton.swift
//  Dash
//
//  Created by Steffi Tan on 3/24/22.
//

import SwiftUI

struct CommentButton: View {
  let count: Int
  var bgColor: AssetsColor
  let action: (() -> Void)?
  
  init(count: Int, bgColor: AssetsColor = .gray_1, action: (() -> Void)? = nil) {
    self.count = count
    self.action = action
    self.bgColor = bgColor
  }
  
  var body: some View {
    Button {
      action?()
    } label: {
      Label(count == 0 ? "" : String(count), image: AssetImage.ic_comment_bubble.name)
        .labelStyle(IconOnTheRightLabelStyle())
        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
    }
    .bgAssetColor(bgColor)
    .cornerRadius(6)
    .buttonStyle(.plain)
  }
}

struct CommentButton_Previews: PreviewProvider {
  static var previews: some View {
    CommentButton(count: 10)
  }
}
