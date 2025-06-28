//
//  NewUsersView.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

struct NewUsersView: View {
  let title: String
  let text: String
  let users: [User]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .fontHeavy(size: 16)
        .fgAssetColor(.black)    
      UsersDisplay(text: text, users: users)
    }
    .padding(.horizontal, 20)
  }
}

struct NewUsersView_Previews: PreviewProvider {
  static var previews: some View {
    NewUsersView(title: "Welcome to the Community",
                 text: "Crispin, Inigo, Yeong-Su and 27 others just joined",
                 users: [User.seed])
  }
}

