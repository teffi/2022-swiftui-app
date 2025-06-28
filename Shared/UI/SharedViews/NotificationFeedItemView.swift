//
//  NotificationFeedItemView.swift
//  Dash
//
//  Created by Steffi Tan on 3/27/22.
//

import SwiftUI

struct NotificationFeedItemView: View {
  enum Destination {
    case profile
    case product
  }
  
  @Environment(\.injected) private var dependencies
  @EnvironmentObject private var tab: TabController
  @State private var linkDestination: NotificationFeedItemView.Destination?
  
  let notification: NotificationFeed.Item
    
  private var showProductThumbnail: Bool {
    switch notification.objectType {
    case .review, .like:
      return true
    default:
      return false
    }
  }
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      HStack(alignment: .top, spacing: 12) {
        userThumbnail
        description
        if showProductThumbnail {
          productThumbnail
            .padding(.horizontal, 4)
        }
      }
      
      NavigationLink(tag: .profile, selection: $linkDestination) {
        if let user = notification.summary.users?.first {
          ProfileScreen(userId: user.id)
            .environment(\.profileScreenPresentation, .link)
            .inject(dependencies)
        }
      } label: { EmptyView() }
      //  Hide default navigation link arrow -
      .buttonStyle(.plain)
      .opacity(0.0)
    }
    .listRowBackground(Color.white)
    .contentShape(Rectangle())
    .onTapGesture {
      if let productId = notification.productId {
        tab.goToProduct(id: productId, reviewId: notification.reviewId)
      }
    }
  }
}

//  MARK: - View
extension NotificationFeedItemView {
  @ViewBuilder private var userThumbnail: some View {
    ImageRender(urlPath: notification.summary.users?.first?.profileImage?.mediumUrl ?? "") { image in
      image.thumbnail()
    }
    .frame(maxWidth: 40, maxHeight: 40)
    .clipInFullCircle()
    .overlay(icon, alignment: .bottomLeading)
    .onTapGesture {
      linkDestination = .profile
    }
  }
  
  @ViewBuilder private var icon: some View {
    if let iconUrl = notification.iconImageUrl, !iconUrl.isEmpty {
      ImageRender(urlPath: notification.iconImageUrl ?? "") { image in
        image
          .icon()
          .frame(width: 18, height: 18)
          .clipInFullCircle()
          .offset(x: -4, y: 2)
      }
    } else {
      EmptyView()
    }
  }
  
  private var productThumbnail: some View {
    ImageRender(urlPath: notification.productImage?.smallUrl ?? "") { image in
      image.thumbnail()
    }
    .modifier(SquareFrame(size: 69, cornerRadius: 8))
  }
  
  private var commentText: some View {
    Text(notification.previewText ?? "")
      .fontRegular(size: 14)
      .fgAssetColor(.black)
      .lineLimit(3)
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .bgAssetColor(.gray_1)
      .cornerRadius(12)
  }
  
  private var reviewText: some View {
    Text(notification.previewText ?? "")
      .lineLimit(2)
      .truncationMode(.tail)
      .fontRegular(size: 14)
      .fgAssetColor(.black, opacity: 0.4)
  }
  
  @ViewBuilder private var descriptionPreview: some View {
    switch notification.objectType {
    case .review, .like:
      reviewText
    case .comment:
      commentText
    case .unsupported:
      EmptyView()
    }
  }
  
  private var description: some View {
    VStack(alignment: .leading, spacing: 8) {
      RichText(notification.summary.displayText)
        .fontRegular(size: 14)
        .fgAssetColor(.black)
      
      descriptionPreview
      
      Text(notification.timeSince ?? "")
        .fontRegular(size: 14)
        .fgAssetColor(.black, opacity: 0.4)
    }
  }
}

struct NotificationFeedItemView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationFeedItemView(notification: NotificationFeed.Item())
  }
}

