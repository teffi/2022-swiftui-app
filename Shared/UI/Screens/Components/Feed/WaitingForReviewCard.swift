//
//  WaitingForReviewCard.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

struct WaitingForReviewCard: View {
  @EnvironmentObject private var tab: TabController
  
  let model: Feed.Subscriptions
  
  var userToDisplay: User? {
    return model.summary.users?.first
  }
  
  var body: some View {
    Card {
      buildContent()
    }.onTapGesture {
      tab.goToProduct(id: model.product.id)
    }
  }
  
  @ViewBuilder func buildContent() -> some View {
    VStack(alignment: .leading) {
      Text(model.title)
        .fontHeavy(size: 16)
        .fgAssetColor(.black)
      // Subscribers
      HStack {
        Label {
          RichText(model.summary.displayText)
            .fontRegular(size: 14)
        } icon: {
          UserWidgetPhoto(imageUrl: userToDisplay?.profileImage?.smallUrl, initials: userToDisplay?.initials ?? "")
            .frame(width: 40, height: 40)
        }
        .labelStyle(CenterAlignedStyle())
        Spacer()
      }.padding(.vertical, 12)
      
      // Product
      HStack(alignment: .center, spacing: 18) {
        ImageRender(urlPath: model.product.image?.largeUrl ?? "", placeholderRadius: 8) { image in
          image.thumbnail()
        }.modifier(SquareFrame(size: 94, cornerRadius: 8))
        
        VStack(alignment: .leading, spacing: 8) {
          Text(model.product.displayName)
            .fontHeavy(size: 16)
            .fgAssetColor(.black)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .padding(.leading, 0)
        }
        Spacer()
      }
      .padding(.vertical, 8)
      
      // Button
      HStack {
        Spacer()
        Button("Be the first to review") {
          print("first to review")
        }
        .disabled(true)
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .fontBold(size: 16)
        .bgAssetColor(.purple)
        .foregroundColor(.white)
        .cornerRadius(8)
        Spacer()
      }
      .padding(.top, 12)
     
    }
    
  }
}


struct WaitingForReviewCard_Previews: PreviewProvider {
  static var previews: some View {
    WaitingForReviewCard(model: Feed.Subscriptions.seed)
  }
}
