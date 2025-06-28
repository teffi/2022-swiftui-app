//
//  ReviewCard.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct ReviewCard: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject private var tab: TabController
  
  @State private var isPresentedActionSheet = false
  @State private var isLiked = false
  @State var like: Loadable<Response> = .idle
  @State private var isPresentedReportSheet = false
  @State private var isPresentedShareSheet = false
  
  private var actionSheetActions: [ReviewActions.Action] {
    if review.user.id == dependencies.appState.userSession.userId {
      return [.share]
    } else {
      return [.share, .report]
    }
  }
  let review: Review
  
  init(review: Review) {
    self.review = review
    _isLiked = .init(initialValue: review.hasLiked)
  }
  
  var body: some View {
    Card {
      VStack(alignment: .leading, spacing: 12) {
        // User and ellipsis
        userWidget
          .floatingEllipsis(tap: $isPresentedActionSheet)
          .reviewActionSheet(isPresented: $isPresentedActionSheet, actions: actionSheetActions) { action in
            switch action {
            case .report:
              isPresentedReportSheet = true
            case .share:
              isPresentedShareSheet = true
            default:
              break
            }
          }
        
        if !review.thumbnailImageUrls.isEmpty {
          ImageThumbnails(urls: review.thumbnailImageUrls)
            .padding(.top, 12)
        }
        
        reviewBody
        
        if let product = review.product {
          productView(product)
        }
        
        // Feedback - Like button
        feedbackView
          .padding(.top, 8)
      }
   
      .sheet(isPresented: $isPresentedReportSheet, onDismiss: {
        // do something on dismiss
      }, content: {
        NavigationView {
          ReportScreen(id: review.id)
            .environment(\.reportType, .review)
        }
      })
      
      .activitySheet(present: $isPresentedShareSheet, items: [review.shareableUrl ?? ""], excludedActivityTypes: nil)
    }
    .onTapGesture {
      if let id = review.product?.id {
        tab.goToProduct(id: id, reviewId: review.id)
      }
    }
    .onChange(of: isLiked) { newValue in
      postLike(status: newValue)
    }
  }
}

// MARK: - Views
extension ReviewCard {
  @ViewBuilder private var userWidget: some View {
    HStack {
      UserWidget(id: review.user.id,
                 name: review.user.widgetDisplay.name,
                 initials: review.user.widgetDisplay.initials,
                 username: review.user.widgetDisplay.username,
                 bio: review.user.widgetDisplay.bio,
                 imageUrl: review.user.widgetDisplay.imageUrl,
                 sentiment: Sentiment(rawValue: review.kind))
      Spacer(minLength: 30)
    }
  }
  
  private var reviewBody: some View {
    ExpandableText(text: .constant(review.body),
                   isReadOnly: .constant(true),
                   font: .regular(size: 16),
                   lineLimit: 8,
                   lineSpacing: 2)
      .fgAssetColor(.black)
      .padding(.vertical, 12)
  }
  
 
  private var feedbackView: some View {
    HStack {
      Spacer()
      CommentButton(count: review.commentCount)
      LikeButton(count: review.likeCount, isSelected: $isLiked) {
        print("pressed like button \(review.id)")
      }
    }
  }
  
  @ViewBuilder private func productView(_ product: Review.Product) -> some View {
    // Product
    HStack(alignment: .center, spacing: 18) {
      ImageRender(urlPath: product.image.mediumUrl ,
                  placeholderRadius: 8) { image in
        image.thumbnail()
      }
                  .modifier(SquareFrame(size: 94, cornerRadius: 8))
      
      VStack(alignment: .leading, spacing: 12) {
        Text(product.displayName)
          .fontHeavy(size: 16)
          .fgAssetColor(.black)
          .lineLimit(3)
          .multilineTextAlignment(.leading)
          .padding(.leading, 0)
        
        SentimentDisplay(size: .small,
                         love: String(product.loveCount),
                         hate: String(product.hateCount))
      }
      Spacer()
    }
  }
  
  @ViewBuilder private func buildPostLike() -> some View {
    switch like {
    case .idle:
      let _ = print("")
      Color.clear
    case .loaded(_):
      Color.clear
    case .failed(_):
      let _ = print("failed review like")
      Color.clear
    case .isLoading(_, _):
      Color.clear
    }
  }
}

//  MARK: - API
extension ReviewCard {
  func postLike(status: Bool) {
    dependencies.interactors.reviewsInteractor.likeReview(reviewId: review.id, status: status, response: $like)
  }
}

struct ReviewCard_Previews: PreviewProvider {
  static var previews: some View {
    ReviewCard(review: Review.seed)
  }
}

