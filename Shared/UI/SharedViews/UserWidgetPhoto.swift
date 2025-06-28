//
//  UserWidgetPhoto.swift
//  Dash
//
//  Created by Steffi Tan on 3/31/22.
//

import SwiftUI

struct UserWidgetPhoto: View {
  var imageUrl: String?
  let initials: String
  
  var body: some View {
    if let imageUrl = imageUrl, !imageUrl.isEmpty {
      imageThumbnail(url: imageUrl)
    } else {
      userInitials
    }
  }
  
  var randomInitialColor: Color {
    return [Color.hex("c05ea5"),Color.hex("E9A448"), Color.hex("BB3E55"), Color.hex("28243F")].randomElement()!
  }
  
  private func imageThumbnail(url: String) -> some View {
    ImageRender(urlPath: url) { image in
      image.thumbnail()
    }
    .clipInFullCircle()
  }
  
  private var userInitials: some View {
    ZStack(alignment: .center) {
      Circle()
        .fill(randomInitialColor)
      Text(initials)
        .fontSemibold(size: 16)
        .fgAssetColor(.white)
        .minimumScaleFactor(0.3)
    }
  }
}

struct UserWidgetPhoto_Previews: PreviewProvider {
  static var previews: some View {
    UserWidgetPhoto(imageUrl: "", initials: "AB")
  }
}
