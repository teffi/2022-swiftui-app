//
//  ProductHeader.swift
//  Dash
//
//  Created by Steffi Tan on 2/10/22.
//

import SwiftUI

struct ProductHeader: View {
  let title: String
  let imageUrl: String
  let love: String
  let hate: String
  let user: User?
  let willShowSentiment: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .center, spacing: 20) {
        
        ImageRender(urlPath: imageUrl, placeholderRadius: 8) { image in
          image.thumbnail()
        }
        .modifier(SquareFrame.init(size: 94, cornerRadius: 8))

        VStack(alignment: .leading, spacing: 12) {
          Text(title)
            .lineLimit(3)
            .fontHeavy(size: 16)
            .fgAssetColor(.black)
            .fixedSize(horizontal: false, vertical: true) //<- when removed, ios14 does not render in multiplelines
            .multilineTextAlignment(.leading)
            .padding(.leading, 0)

          if willShowSentiment {
            SentimentDisplay(size: .small, love: love, hate: hate)
              .fixedSize(horizontal: false, vertical: true)
          }
          /*
           Note:
           .fixedSize(horizontal: false, vertical: true) fixes resizing issues of views inside a stack.
           So far it only appears on ios14. However there's a weird behavior where `ReviewCard` has also the same layout but doesn't appear to have an issue on ios14.
           */
        }
        //  Add spacer to fill up unused width space and elements will stick on the leading edge
        Spacer()
      }
     
      buildOptionalUser()
      
    } // End VStack
  }
}

// MARK: - View Builders
extension ProductHeader {
  @ViewBuilder func buildOptionalUser() -> some View {
    if let user = user {
      Label {
        RichText("Added by **\(user.displayName)**")
          .fontRegular(size: 11.5)
      } icon: {
        if let imageUrl = user.profileImage?.smallUrl, !imageUrl.isEmpty {
          ImageRender(urlPath: user.profileImage?.largeUrl ?? "") { image in
            image.thumbnail()
          }
          .modifier(CircleClip(size:20))
        }
      }
      .padding(0)
    }
  }
}

struct ProductHeader_Previews: PreviewProvider {
  static var previews: some View {
    ProductHeader(title: "COSRX Low pH Good Morning Gel Cleanser",
                  imageUrl: "https://picsum.photos/400/500",
                  love: "4",
                  hate: "3",
                  user: User.seed,
                  willShowSentiment: true)
  }
}

