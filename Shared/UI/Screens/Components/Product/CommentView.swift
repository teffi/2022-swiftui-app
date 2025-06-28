//
//  CommentView.swift
//  Dash
//
//  Created by Steffi Tan on 3/9/22.
//

import SwiftUI

struct CommentView: View {
  var comment: Comment
  var contentBgColor: AssetsColor = .white
  var body: some View {
    VStack (alignment: .leading) {
      userWidget
      content
    }
  }
}

//  MARK: Views
extension CommentView {
  @ViewBuilder private var userWidget: some View {
    HStack {
      UserWidget(size: .compact,
                 id: comment.user.id,
                 name: comment.user.displayName,
                 initials: comment.user.widgetDisplay.initials,
                 username: comment.user.widgetDisplay.username,
                 bio: comment.user.widgetDisplay.bio,
                 imageUrl: comment.user.widgetDisplay.imageUrl)
      Spacer(minLength: 30)
    }
  }
  
  private var content: some View {
    Text(comment.body)
      .lineLimit(nil)
    // .fixedSize will guarantee that text will respect the proposed horizontal space
    // and take as much vertical space as needed. ref: https://stackoverflow.com/a/57677746/1045672
      .fixedSize(horizontal: false, vertical: true)
      .fontRegular(size: 14)
      .fgAssetColor(.black)
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .bgAssetColor(contentBgColor)
      .cornerRadius(12)
  }
}
struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    CommentView(comment: Comment.seed)
      .background(Color.red)
      .padding(.leading, 12)
  }
}
