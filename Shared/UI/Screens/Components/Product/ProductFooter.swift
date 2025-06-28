//
//  ProductFooter.swift
//  Dash
//
//  Created by Steffi Tan on 2/10/22.
//

import SwiftUI
///  IMPT:  `ProductEnv` environmentObject is needed for ProductLoveHateLink
/// - Currently, it is attached by the footer ancestor therefore we dont need to manually attach it.
/// - You can access the env by declaring `@EnvironmentObject private var productEnv: ProductEnv`
struct ProductFooter: View {
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  @Binding var stateStore: ProductStateStore
  // Object for write revew
  @ObservedObject var reviewForm: ProductReviewForm
  /// Subscribe UI state
  @Binding var isSubscribed: Bool
  
  private var viewInsets: EdgeInsets {
    return EdgeInsets(top: 20,
                      leading: 20,
                      bottom: safeAreaInsets.bottom > 0 ? 10 : 20,
                      trailing: 20)
  }
  
  var body: some View {
    switch stateStore.footer {
    case .subscribe:
      buildSubscribe()
    case let .subscribers(text, users):
      buildSubscribers(text: text, users: users)
    case .write:
      buildWriteReview()
    case .none:
      EmptyView()
    }
  }
}

extension ProductFooter {
  enum ViewType {
    //  Add to watchlist
    case subscribe
    //  xxx people subscribed
    case subscribers(text: String, users: [User])
    //  write review
    case write
    case none
  }
  
  // MARK: - Functions
  @ViewBuilder func buildSubscribers(text: String, users: [User]) -> some View {
    //  Wrap in HStack so we can use spacer to fill the remaining width
    //  forcing the label to occupy its fitting size on the left side
    HStack {
      UsersDisplay(text: text, users: users)
      Spacer()
    }
    .padding(viewInsets)
  }
  
  @ViewBuilder func buildSubscribe() -> some View {
    VStack(spacing: 8) {
      Text("Add to watchlist")
        .fontBold(size: 16)
        .fgAssetColor(.black)
      Text("Ask the community to review this")
        .fontRegular(size: 14)
        .fgAssetColor(.black)
        .padding(.bottom, 20)
      Button("Ask for reviews") {
        isSubscribed.toggle()
      }
      .fontHeavy(size: 14)
      .padding(.horizontal, 24)
      .padding(.vertical, 10)
      .bgAssetColor(.light_purple_translucent)
      .fgAssetColor(.purple)
      .cornerRadius(8)
    }
    .padding(.vertical, 40)
  }
  
  @ViewBuilder func buildWriteReview() -> some View {
    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Write a review")
            .fontBold(size: 16)
          Text("Share your thoughts and feelings")
            .fontRegular(size: 14)
        }
        .fgAssetColor(.black)
        //  Use spacer instead of stack spacing so
        //  we can fill the space in between while keeping it at minimum of 20.
        Spacer(minLength: 20)
        ProductLoveHateLink(form: reviewForm,
                            size: 40,
                            hasShadow: true,
                            showTitle: false,
                            spacing: 18)
      }
      .padding(viewInsets)
    }
    .background(
      Color.white.shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: -5)
        .ignoresSafeArea()
    )
  }
}

/// Vertiacally center align title and  icon regardless of icon size
struct CenterAlignedStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 12) {
      configuration.icon
      configuration.title
    }
  }
}

struct ProductFooter_Previews: PreviewProvider {
  static var previews: some View {
//    ProductFooter(type: .subscribe)
//    ProductFooter(type: .subscribers(text: "xx others", imageUrls: ["sample"]),
//                  reviewForm: ProductReviewForm())
//    ProductFooter(type: .subscribe,
//                  reviewForm: ProductReviewForm())
    ProductFooter(stateStore: .constant(.init(isSubscribed: true, reviewCount: 10, footer: .write)), reviewForm: ProductReviewForm(), isSubscribed: .constant(false))
  }
}

