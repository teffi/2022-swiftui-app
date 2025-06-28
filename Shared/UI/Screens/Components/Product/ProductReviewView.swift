//
//  ProductReviewView.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

typealias CommentEditor = (reviewId: String, isActive: Bool)
struct CommentEditorNew: Equatable {
  enum Kind {
    case review, comment
  }
  var kind: Kind
  var id: String
  var commentReviewId: String?
  var body: String? = nil
  
  var isActive = false
  
  static func ==(lhs: CommentEditorNew, rhs: CommentEditorNew) -> Bool {
    return lhs.id == rhs.id &&
    lhs.kind == rhs.kind &&
    lhs.body == rhs.body &&
    lhs.commentReviewId == rhs.commentReviewId &&
    lhs.isActive == rhs.isActive
  }
}

struct ProductReviewView: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject var productEnv: ProductEnv
  
  let review: Review
  var form: ProductReviewForm
  var hasDivider = false
  var isHighlighted = false
  @Binding var commentEditor: CommentEditorNew
  @State private var isLiked = false
  @State private var like: Loadable<Response> = .idle
  @State private var delete: Loadable<Response> = .idle
  @State private var commentDelete: Loadable<Response> = .idle
  @State private var isPresentedShareSheet = false
  @State private var reportSheet: ReportSheetType?
  @State private var alert: (String, String)?
  @State var actionDestination: ProductReviewView.ActionLink?
  @State private var actionSheetType: ActionSourceType?
  @State private var deleteConfirmationSource: ActionSourceType?

  init(review: Review,
       form: ProductReviewForm,
       hasDivider: Bool = false,
       isHighlighted: Bool = false,
       commentEditor: Binding<CommentEditorNew> = .constant(.init(kind: .review, id: "", isActive: false))) {
    self.review = review
    self.hasDivider = hasDivider
    self.isHighlighted = isHighlighted
    self.form = form
    _isLiked = .init(initialValue: review.hasLiked)
    _commentEditor = commentEditor
  }
  
  var body: some View {
    ZStack {
      buildContent()
        .onChange(of: isLiked) { newValue in
          postLike(status: newValue)
        }
        .alert(item: $deleteConfirmationSource) { source in
          switch source {
          case .comment(let comment):
            return deleteCommentAlert(comment)
          case .review:
            return deleteReviewAlert
          }
        }
      //  Report modal
        .sheet(item: $reportSheet) {
          // on dismiss, reset report sheet?
        } content: { reportSheet in
          NavigationView {
            switch reportSheet.type {
            case .comment:
              ReportScreen(id: reportSheet.id)
                .environment(\.reportType, .comment)
            case .review:
              ReportScreen(id: reportSheet.id)
                .environment(\.reportType, .review)
            case .user:
              ReportScreen(id: reportSheet.id)
                .environment(\.reportType, .user)
            }
          }
          
        }
      
      buildDelete()
      buildDeleteComment()
      
      NavigationLink(tag: .reviewForm, selection: $actionDestination) {
        ProductReviewFormScreen(form: form)
          .inject(dependencies)
          .environment(\.editMode, .constant(.active))
          .environmentObject(productEnv)
      } label: { EmptyView() }
      
//      NavigationLink(tag: .report, selection: $actionDestination) {
//        Text("This is a report screen")
//      } label: { EmptyView }()
    }
  }

}

// MARK: - Views
extension ProductReviewView {
  @ViewBuilder func buildContent() -> some View {
    VStack(alignment: .leading, spacing: 12) {
      // User and ellipsis
      userWidget
      //  Images
      if !review.thumbnailImageUrls.isEmpty {
        ImageThumbnails(urls: review.thumbnailImageUrls)
          .padding(.top, 12)
      }
      //  Body
      reviewBody
      //  Feedback
      feedbackView.padding(.top, 0)
      // Comments
      if let comments = review.comments, comments.count > 0 {
        commentsList(comments)
      }
      if hasDivider {
        //  Offset equivalent to bottom padding so the divider moves exactly to the bottom of the view
        Divider().offset(y: 20)
      }
    }
    .padding(20)
    
    .actionSheet(item: $actionSheetType, content: { sheetType in
      switch sheetType {
      case .comment(let comment):
        return commentActionSheet(with: comment)
      case .review:
        return reviewActionSheet
      }
    })
    .activitySheet(present: $isPresentedShareSheet, items: [review.shareableUrl ?? ""],
                   excludedActivityTypes: nil)
  }

  @ViewBuilder private var userWidget: some View {
    HStack {
      UserWidget(id: review.user.id,
                 name: review.user.widgetDisplay.name,
                 initials: review.user.widgetDisplay.initials,
                 username: review.user.widgetDisplay.username,
                 bio: review.user.widgetDisplay.bio,
                 imageUrl: review.user.widgetDisplay.imageUrl,
                 sentiment: Sentiment.parse(review.kind))
      Spacer(minLength: 30)
    }
    .overlay(alignment: .topTrailing) {
      Button {
        actionSheetType = .review
      } label: {
        Image(systemName: "ellipsis")
          .icon()
          .fgAssetColor(.black)
          .opacity(0.4)
      }
      .frame(width: 18, height: 18, alignment: .center)
      .padding(4)
      .contentShape(Rectangle())
    }
  }
  
  private var reviewBody: some View {
    ExpandableText(text: .constant(review.body),
                   isReadOnly: .constant(false),
                   font: .regular(size: 16),
                   lineLimit: 8,
                   lineSpacing: 2,
                   containerBgColor: review.isHighlighted ? .purple_powder : .white)
      .fgAssetColor(.black)
      .padding(.vertical, 12)
  }
  
  @ViewBuilder private func commentsList(_ comments: [Comment]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      ForEach(comments) { comment in
        CommentView(comment: comment, contentBgColor: isHighlighted ? .white : .gray_1)
          .opacity(comment.isTemporary ? 0.5 : 1)
          .padding(.leading, 12)
          .overlay(alignment: .topTrailing) {
            Button {
              print("comment id is \(comment.id)")
              actionSheetType = .comment(comment: comment)
            } label: {
              Image(systemName: "ellipsis")
                .icon()
                .fgAssetColor(.black)
                .opacity(0.4)
            }
            .frame(width: 18, height: 18, alignment: .center)
            .padding(4)
            .contentShape(Rectangle())
          }
      }
    }
    .overlay(Rectangle()
              .frame(width: 2, height: nil, alignment: .leading)
              .fgAssetColor(.gray_2),
             alignment: .leading)
  }
  
  @ViewBuilder private var feedbackView: some View {
    HStack {
      Text("Add Reply")
        .fontBold(size: 14)
        .fgAssetColor(.black)
        .onTapGesture {
          //commentEditor = (reviewId: review.id, isActive: true)
          print("comment editor \(commentEditor)")
          commentEditor.kind = .review
          commentEditor.id = review.id
          commentEditor.isActive = true
        }
      Spacer()
      CommentButton(count: review.commentCount, bgColor: review.isHighlighted ? .white : .gray_1)
      LikeButton(count: review.likeCount, isSelected: $isLiked, bgColor: review.isHighlighted ? .white : .gray_1) {
        print("pressed like button \(review.id)")
      }
    }
  }
  
  //  MARK: - Actionsheets
  private func commentActionSheet(with comment: Comment) -> ActionSheet {
    var buttons: [Alert.Button] = []
    let edit = Alert.Button.default(Text("Edit"), action: {
      commentEditor.kind = .comment
      commentEditor.commentReviewId = review.id
      commentEditor.id = comment.id
      commentEditor.body = comment.body
      commentEditor.isActive = true
    })
    let delete = Alert.Button.destructive(Text("Delete"), action: { deleteConfirmationSource = .comment(comment: comment) })
    let report = Alert.Button.default(Text("Report"), action: {
      reportSheet = .init(id: comment.id, type: .comment)
    })
    if comment.user.id == dependencies.appState.userSession.userId {
      buttons = [edit, delete]
    } else {
      buttons = [report]
    }
    buttons.append(.cancel())
    return ActionSheet(title: Text("Select"), message: nil, buttons: buttons)
  }
  
  private var reviewActionSheet: ActionSheet {
    var buttons: [Alert.Button] = []
    let edit = Alert.Button.default(Text("Edit"), action: { actionDestination = .reviewForm })
    let delete = Alert.Button.destructive(Text("Delete"), action: { deleteConfirmationSource = .review })
    let share = Alert.Button.default(Text("Share"), action: { isPresentedShareSheet = true })
    let report = Alert.Button.default(Text("Report"), action: {
      reportSheet = .init(id: review.id, type: .review)
    })
    
    if review.user.id == dependencies.appState.userSession.userId {
      buttons = [edit, share, delete]
    } else {
      buttons = [share, report]
    }
    buttons.append(.cancel())
    return ActionSheet(title: Text("Select"), message: nil, buttons: buttons)
  }
  
  //  MARK: - Alert actions
  private var deleteReviewAlert: Alert {
    Alert(title: Text("Delete review"),
          message:  Text("Are you sure you want to delete this review?"),
          primaryButton: .destructive(Text("Delete"), action: {
      deleteReview()
    }), secondaryButton: .cancel())
  }
  
  private func deleteCommentAlert(_ comment: Comment) -> Alert {
    Alert(title: Text("Delete comment"),
          message:  Text("Are you sure you want to delete your comment?"),
          primaryButton: .destructive(Text("Delete"), action: {
      deleteComment(commentId: comment.id)
    }), secondaryButton: .cancel())
  }
  
  //  MARK: - Loadables
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
  
  @ViewBuilder func buildDelete() -> some View {
    switch delete {
    case .idle:
      Color.clear
    case .loaded(_):
      Color.clear
        .onAppear {
          productEnv.shouldRefreshData = true
          /**
           IMPORTANT: Revert to .idle after changing productEnv flag. We dont need to save the loaded state or else productEnv flag will be assigned every time this view gets called which could cause a  loop on the statements being executed on change in shouldRefreshData. For example, data reloading on Product screen.
           */
          commentDelete = .idle
        }
    case .failed(let response):
      Color.clear.onAppear {
        var alertTitle = "Something went wrong"
        var alertMessage = response.localizedDescription
        if let err = response.asAPIError {
          alertTitle = err.alert.title
          alertMessage = err.alert.message
        }
        dependencies.appState.showAlert(title: alertTitle,
                                        message: alertMessage)
      }
    case .isLoading(_, _):
      Color.black.opacity(0.05).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
  
  @ViewBuilder func buildDeleteComment() -> some View {
    switch commentDelete {
    case .idle:
      Color.clear
    case .loaded(_):
      Color.clear
        .onAppear {
          productEnv.shouldRefreshData = true
          /**
           IMPORTANT: Revert to .idle after changing productEnv flag. We dont need to save the loaded state or else productEnv flag will be assigned every time this view gets called. Causing a possible loop of statements being executed on change in shouldRefreshData. For example, data reloading on Product screen.
           */
          commentDelete = .idle
        }
    case .failed(let response):
      Color.clear.onAppear {
        var alertTitle = "Something went wrong"
        var alertMessage = response.localizedDescription
        if let err = response.asAPIError {
          alertTitle = err.alert.title
          alertMessage = err.alert.message
        }
        dependencies.appState.showAlert(title: alertTitle,
                                        message: alertMessage)
      }
    case .isLoading(_, _):
      Color.black.opacity(0.05).ignoresSafeArea()
      ProgressView().frame(maxHeight: .infinity)
    }
  }
}

//  MARK: - API
extension ProductReviewView {
  func postLike(status: Bool) {
    dependencies.interactors.reviewsInteractor
      .likeReview(reviewId: review.id, status: status, response: $like)
  }
  
  func deleteReview() {
    dependencies.interactors.reviewsInteractor
      .deleteReview(id: review.id, response: $delete)
  }
  
  func deleteComment(commentId: String) {
    dependencies.interactors.reviewsInteractor.deleteComment(id: commentId, response: $commentDelete)
  }
}
//  MARK: -
extension ProductReviewView {
  enum ActionLink {
    case reviewForm, report
  }

  enum ActionSourceType: Identifiable {
    case comment(comment: Comment), review
    var id: String { UUID().uuidString }
  }
  
  struct ReportSheetType: Identifiable {
    let id: String
    let type: ReportTypeKey.ReportType
  }
}

struct ProductReviewView_Previews: PreviewProvider {
  static var previews: some View {
    ProductReviewView(review: Review.seed, form: ProductReviewForm())
  }
}

