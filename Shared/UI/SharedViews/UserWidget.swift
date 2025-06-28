//
//  UserWidget.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct UserWidget: View {
  @Environment(\.injected) private var dependencies: DIContainer
  var size: UserWidget.Size = .normal
  let id: String
  let name: String
  let initials: String
  let username: String
  let bio: String
  let imageUrl: String
  // If assigned, it creates an overlay icon of the given sentiment
  var sentiment: Sentiment? = nil
  
  var body: some View {
    NavigationLink {
      ProfileScreen(userId: id)
        .inject(dependencies)
        .environment(\.profileScreenPresentation, .link)
    } label: {
      HStack (alignment: .center) {
        
        UserWidgetPhoto(imageUrl: imageUrl, initials: initials)
          .frame(width: size.thumbnail, height: size.thumbnail)
          .overlay(sentimentOverlay, alignment: .bottomLeading)
        
        VStack(alignment: .leading, spacing: 4) {
          nameAndUsername
          if !bio.isEmpty {
            Text(bio)
              .fontSemibold(size: 11.5)
              .fgAssetColor(.black, opacity: 0.4)
          }
        }
      }
    }
    .appButtonStyle(.flatLink)
  }

}
//  MARK: - Views
extension UserWidget {
  @ViewBuilder private var nameAndUsername: some View {
    HStack(alignment: .center, spacing: 8) {
      Text(name)
        .fontHeavy(size: size.name)
        .fgAssetColor(.black)
      
      Text(username.lowercased())
        .fontSemibold(size: 11.5)
        .fgAssetColor(.black, opacity: 0.4)
    }
  }
  @ViewBuilder private var sentimentOverlay: some View {
    if let sentiment = sentiment {
      switch sentiment {
      case .love:
        LoveImage()
          .frame(width: 18, height: 18)
          .offset(x: -4, y: 4)
      case .hate:
        HateImage()
          .frame(width: 18, height: 18)
          .offset(x: -4, y: 4)
      }
    }
  }
}
//  MARK: - Model
extension UserWidget {
  struct ViewModel {
    let name: String
    let initials: String
    let username: String
    let bio: String
    let imageUrl: String
  }
  
  enum Size {
    case normal, compact
    
    var name: CGFloat {
      switch self {
      case .normal:
        return 16
      case .compact:
        return 14
      }
    }
    
    var thumbnail: CGFloat {
      switch self {
      case .normal:
        return 36
      case .compact:
        return 24
      }
    }
  }
}

struct UserWidget_Previews: PreviewProvider {
  static var previews: some View {
    UserWidget(id: "1",
               name: "John",
               initials: "JL",
               username: "@johnappleseed",
               bio: "I love apples",
               imageUrl: "https://picsum.photos/400/500",
               sentiment: .hate)
  }
}

