//
//  UsersDisplay.swift
//  Dash
//
//  Created by Steffi Tan on 2/17/22.
//

import SwiftUI

struct UsersDisplay: View {
  let text: String
  let users: [User]

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      HStack(alignment: .top, spacing: -3) {
        ForEach(users) { user in
          UserWidgetPhoto(imageUrl: user.profileImage?.smallUrl, initials: user.initials)
            .frame(width: 36, height: 36)
            .circularBorder()
        }
      }
      RichText(text)
        .fontRegular(size: 14)
        .fgAssetColor(.black)
    }
  }
}

struct UsersDisplay_Previews: PreviewProvider {
  static var previews: some View {
    UsersDisplay(text: "**Crispin, Inigo, Yeong-Su** and 27 others just joined",
                 users: [User.seed])
  }
}

