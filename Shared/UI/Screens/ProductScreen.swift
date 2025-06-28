//
//  ProductScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI
import Introspect

struct ProductScreen: View {
  @Environment(\.injected) private var dependencyEnv: DIContainer
  
  @StateObject private var productEnv = ProductEnv()
  @StateObject private var reviewForm: ProductReviewForm

  //  Product
  @State var product: Loadable<Product>
  @State var subscription: Loadable<Response>
  /// State storage for Product api response
  @State var stateStore = ProductStateStore()
  /// State for footer and sheet subscribe state. Use this in UI bindings. Do not use`ProductStore`
  @State private var isSubscribed = false
  @State private var footerHeight: CGFloat = 0
  
  // Reviews + comments
  @State var reviews: Loadable<Reviews>
  @State var comment: Loadable<Review.PostComment>
  @State var commentUpdate: Loadable<Review.PostComment>
  
  @StateObject var reviewsStore = ReviewsStore()
  private var isLoadingReviews: Bool {
    switch reviews {
    case .isLoading:
      return true
    default:
      return false
    }
  }
  
  @State private var isPresentedProductActions = false
  @State private var isPresentedComingSoonAlert = false
    
  let id: String
  let reviewId: String?
  
  init(id: String, reviewId: String? = nil, questionId: String? = nil) {
    self.id = id
    self.reviewId = reviewId
    _product = .init(initialValue: .idle)
    _reviews = .init(initialValue: .idle)
    _comment = .init(initialValue: .idle)
    _commentUpdate = .init(initialValue: .idle)
    _subscription = .init(initialValue: .idle)
    //  StateObject initialisation
    //  ref: https://swiftui-lab.com/random-lessons/#data-10
    _reviewForm = StateObject(wrappedValue: ProductReviewForm(questionId: questionId))
  }
  
  /// Init with data injection for testing or preview configuration
  /// - Parameters:
  ///   - product: `Product`
  ///   - reviews: `Reviews`
  ///   - footer: `ProductFooter.ViewType`
  ///   - showEditor: `Bool`
  init(product: Product, reviews: Reviews, footer: ProductFooter.ViewType = .none, showEditor: Bool = false) {
    self.id = product.id
    self.reviewId = nil
    _product = .init(initialValue: .loaded(Product.seed))
    _reviews = .init(initialValue: .loaded(reviews))
    _comment = .init(initialValue: .idle)
    _commentUpdate = .init(initialValue: .idle)
    let editor = CommentEditorNew(kind: .review, id: "123", isActive: showEditor)
    _commentEditor = .init(initialValue: editor)
    _subscription = .init(initialValue: .idle)
    _reviewForm = StateObject(wrappedValue: ProductReviewForm())
  }
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          buildHeader()
          buildReviews()
          if reviewsStore.hasNextPage {
            let _ = print("product : show loading state for next page")
            loadMoreIndicator
          }
        } // end LazyVStack
        .padding(.top, 20)
        .padding(.bottom, commentEditor.isActive ? 80 : 0)
      }
      .padding(.bottom, footerHeight)
      
      // Add comment view when editor is set as active else show footer.
      if commentEditor.isActive {
        commentEditorBox
        //  Important: Place introspection after all view modifications
          .introspectTextView { view in
            view.showsVerticalScrollIndicator = false
            //  TODO: Unstable. Doesn't work sometimes.
            view.becomeFirstResponder()
          }
      } else {
        ProductFooter(stateStore: $stateStore,
                      reviewForm: reviewForm,
                      isSubscribed: $isSubscribed)
          .background(Color.white.ignoresSafeArea())
          .background(GeometryReader {
            //  Pass the height of footer to a preference
            Color.clear.preference(key: FooterHeightKey.self,
                                   value: $0.frame(in: .local).size.height)
          })
          .environmentObject(productEnv)
      }
      
      buildPostSubscription()
        .alert(isPresented: $isPresentedComingSoonAlert) {
          Alert(title: Text("Coming soon"),
                message: Text(""),
                dismissButton: .default(Text("OK"), action: {
          }))
        }
      
      buildPostComment()
    } // end ZStack
    
    //  Pass footer height changes to a variable
    .onPreferenceChange(FooterHeightKey.self) {
      print("footer height value \($0)")
      $footerHeight.wrappedValue = $0
    }
    
    //  Only show ellipsis toolbar if use is unsubscribed.
    .toolbarEllipsis(placement: .navigationBarTrailing, willShow: !stateStore.isSubscribed, action: {
      isPresentedProductActions = true
    })
    
    //  Product observer
    .onChange(of: product.value, perform: { _ in
      syncEnvironment()
    })
    
    //  Subscription observer
    .onChange(of: isSubscribed, perform: { newValue in
      print("did change subscription status to \(newValue)")
      subscribe(status: newValue)
    })
    
    //  Reviews page
    .onChange(of: reviewsStore.shouldLoadMore, perform: { shouldLoadMore in
      print("should load: \(shouldLoadMore), request next page \(reviewsStore.nextPage)")
      if shouldLoadMore && !isLoadingReviews,
          let nextPage = reviewsStore.nextPage {
        loadReviews(page: nextPage)
        print("request next page")
      }
    })
    .onChange(of: productEnv.shouldRefreshData, perform: { shouldRefresh in
      print("should refresh \(shouldRefresh)")
      if shouldRefresh {
        reloadEverything()
        //  Reset back
        productEnv.shouldRefreshData = false
      }
    })
    //  Clear text editor when user selected other review
    .onChange(of: commentEditor) { newEditor in
      //  TODO: Scroll to the position of the review id.
      commentText = newEditor.body ?? ""
    }
    
    .onAppear {
      print("product on appear")
      // Comment update
      switch commentUpdate {
      case .loaded:
        print("successful comment update")
      case .failed:
        print("failed comment update")
      default:
        break
      }
    }
    .environmentObject(productEnv)
    .navigationBarHidden(false)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  // MARK: - View Builders
  
  //  PRODUCT
  @ViewBuilder func buildHeader() -> some View {
    let _ = print("product rendering header")
    switch product {
    case .idle:
      // Render a clear color and start the loading process
      // when the view first appears, which should make the
      // view model transition into its loading state:
      Color.clear
        .onAppear(perform: loadInfo)
    case .loaded(let product):
      ProductHeader(title: product.displayName,
                    imageUrl: product.image.largeUrl,
                    love: String(product.loveCount),
                    hate: String(product.hateCount),
                    user: product.user,
                    willShowSentiment: product.reviewCount > 0)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
        .actionSheet(isPresented: $isPresentedProductActions, content: {
          buildActionSheet()
        })
    case .failed(_):
      Text("product: failed header data")
    case .isLoading(_, _):
      headerSkeleton
    }
  }
  
  //  REVIEWS
  @ViewBuilder private func buildReviews() -> some View {
    switch reviews {
    case .idle:
      Color.clear
        .onAppear {
          loadReviews(page: 1)
        }
    case .loaded(_):
      if reviewsStore.reviews.isEmpty {
        noReview
      } else {
        reviewsContent
          .onAppear {
            let _ = print("product loaded data")
            reviewsStore.shouldLoadMore = false
          }
      }
    case .failed(_):
      Text("product: failed header data")
    case .isLoading:
      if reviewsStore.shouldLoadMore {
        reviewsContent
      } else {
        reviewSkeleton
      }
    }
  }
  
  @ViewBuilder var reviewsContent: some View {
    ForEach(reviewsStore.reviews) { review in
      reviewContentRow(for: review, form: reviewsStore.getFormOfReview(id: review.id))
        .onAppear {
          reviewsStore.loadMoreIfNeeded(current: review)
        }
    }
  }
  
  @ViewBuilder private func reviewContentRow(for review: Review, form: ProductReviewForm) -> some View {
    let isLastReview = reviewsStore.isLastReview(review)
    let isFirstReview = reviewsStore.isFirstReview(review)
    let isHighlighterd = review.isHighlighted
    let willShowDivider = !isLastReview && !isHighlighterd
    
    if isFirstReview && !isHighlighterd {
      Divider()
    }
    
    ProductReviewView(review: review,
                      form: form,
                      hasDivider: willShowDivider,
                      isHighlighted: review.isHighlighted,
                      commentEditor: $commentEditor)
      .padding(.top, isFirstReview ? 10 : 0)
      .bgAssetColor(review.isHighlighted ? .purple_powder : .white)
      
  }
  
  private var loadMoreIndicator: some View {
    HStack {
      Spacer()
      ProgressView()
      Spacer()
    }
  }
  
  //  SUBSCRIPTION
  @ViewBuilder private func buildPostSubscription() -> some View {
    switch subscription {
    case .idle:
      let _ = print("")
      Color.clear
    case .loaded(_):
      Color.clear
        .onAppear {
          //  Initiate a product data reload to get updated list of subscribers to show on subscribers footer. Only applicable for when there's no review because thats the only state we need to show the subscribers list.
          if stateStore.reviewCount < 1 {
            product = .idle
            loadInfo()
          } else {
            //  Sync UI state to statestore
            stateStore.isSubscribed = isSubscribed
          }
        }
    case .failed(let response):
      let _ = print("failed product subscription")
      Color.clear
        .onAppear {
          var alertTitle = "Something went wrong"
          var alertMessage = response.localizedDescription
          if let err = response.asAPIError {
            alertTitle = err.alert.title
            alertMessage = err.alert.message
          }
          dependencyEnv.appState.showAlert(title: alertTitle,
                                           message: alertMessage)
        }
    case .isLoading(_, _):
      let _ = print("product subscription is loading")
      Color.clear
    }
  }
  
  //  COMMENT
  @ViewBuilder private func buildPostComment() -> some View {
    switch comment {
    case .idle:
      Color.clear
    case .loaded(let comment):
      Color.clear
        .onAppear {
          reviewsStore.updateTemporaryComment(reviewId: comment.review.id,
                                     comment: .init(id: comment.id,
                                                    body: comment.body,
                                                    user: comment.user))
        }
    case .failed(let response):
      let _ = print("failed product comment")
      Color.clear
        .onAppear {
          var alertTitle = "Something went wrong"
          var alertMessage = response.localizedDescription
          if let err = response.asAPIError {
            alertTitle = err.alert.title
            alertMessage = err.alert.message
          }
          dependencyEnv.appState.showAlert(title: alertTitle,
                                           message: alertMessage)
        }
    case .isLoading(_, _):
      let _ = print("post comment is loading")
      Color.clear
    }
  }
  
  private var noReview: some View {
    ZStack(alignment: .center) {
      VStack(alignment: .center, spacing: 67) {
        VStack(spacing: 6) {
          Text("No reviews yet")
            .fontBold(size: 20)
            .fgAssetColor(.black, opacity: 0.4)
            .multilineTextAlignment(.center)
          Text("Be the first to leave review")
            .fontRegular(size: 16)
            .fgAssetColor(.black, opacity: 0.4)
            .multilineTextAlignment(.center)

        }
        ProductLoveHateLink(form: reviewForm, size: 61, hasShadow: true, showTitle: true, spacing: 44)
          .environmentObject(productEnv)
      }
    }
    .padding(.top, 100)
    .frame(maxWidth: .infinity)
  }
  
  //  MARK: - Comments
  //  TextEditor with behaviour similar with iMessage.
  //  The view expands up to a certain height.
  //  How: Uses a combination of TextEditor and Text for resizing.
  //  Based from: https://stackoverflow.com/a/68550998/1045672
  
  /// Holds the height used in the TextEditor
  @State private var textEditorHeight: CGFloat = 40
  
  /// Binding property of textEditorHeight with custom set overrides.
  /// Spec: `textEditorHeight` will always hold a min:40 and max: 200 value.
  private var editorHeight: Binding<CGFloat> {
    Binding<CGFloat>(get: {
      return self.textEditorHeight
    }, set: {
      self.textEditorHeight = min(max($0, 40), 200)
    })
  }
  
  @State private var commentText = ""
  /// Used to determine when to show and hide the text editor.
  /// It holds a review identifier which triggered the editor.
  /// This is connected to `ProductReviewView` where the ui to start comment workflow is hosted.
  //@State private var commentEditor: CommentEditor = (reviewId: "", isActive: false)
  @State private var commentEditor: CommentEditorNew = .init(kind: .review, id: "", isActive: false)
  
  private var commentEditorBox: some View {
    VStack(alignment: .leading, spacing: 0) {
      Divider()
      
      switch commentEditor.kind {
      case .review:
        //  Show the name to whom the user is replying
        if let user = getUserInReview(id: commentEditor.id) {
          RichText("Replying to **\(user.displayName)**")
            .fontSemibold(size: 12)
            .fgAssetColor(.black, opacity: 0.4)
            .padding(.horizontal, 12)
            .padding(.top, 10)
        }
      case .comment:
        RichText("Editing")
          .fontSemibold(size: 12)
          .fgAssetColor(.black, opacity: 0.4)
          .padding(.horizontal, 12)
          .padding(.top, 10)
      }
      
      HStack(alignment: .bottom, spacing: 10) {
        TextEditor(text: $commentText)
          .fontRegular(size: 14.0)
          .frame(height: textEditorHeight)
          .offset(x: 10, y: 3)
        Button {
          
          switch commentEditor.kind {
          case .review:
            //  Update UI with temporary comment.
            postTemporaryComment()
            // Send comment to server
            postComment(reviewId: commentEditor.id, body: commentText)
          case .comment:
            reviewsStore.saveEditedComment(reviewId: commentEditor.commentReviewId ?? "", commentId: commentEditor.id, body: commentText)
            updateComment(id: commentEditor.id, body: commentText)
            
          }
          
          clearEditor()
          KeyboardResponder.dismiss()
        } label: {
          Image.asset(.ic_send)
            .icon()
            .frame(width: 28, height: 28, alignment: .center)
        }
        .offset(x: -10, y: -6)
      }
      .bgAssetColor(.white)
      .addBorder(color: .gray_2, cornerRadius: 20)
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
    }
    //  IMPORTANT:
    //  Add Text as overlay and outside the TextEditor container to avoid the container adapting to the Text height
    .overlay(alignment: .topLeading, content: {
      Text(commentText)
        .fontRegular(size: 14)
        .foregroundColor(.clear)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GeometryReader {
          Color.clear.preference(key: EditorHeightKey.self,
                                 value: $0.frame(in: .local).size.height)
        })
        .padding(.horizontal, 20)
        .opacity(0)
    })
    .bgAssetColor(.white)
    .onPreferenceChange(EditorHeightKey.self) { editorHeight.wrappedValue = $0 + 10 }
  }
  
  //  MARK: - Functions
  private func buildActionSheet() -> ActionSheet {
    var buttons: [Alert.Button] = []
    //  Use statestore for condition because we need to use state from product api.
    if !stateStore.isSubscribed {
      buttons.append(.default(Text("Notify me about this product"), action: {
        //  Toggle the subscribe UI state property. NOT statestore.
        isSubscribed.toggle()
      }))
    }
//    buttons.append(.default(Text("Share"), action: {
//      isPresentedComingSoonAlert = true
//    }))
    buttons.append(.cancel())
    return ActionSheet(title: Text("Select"), buttons: buttons)
  }
}

// MARK: - Helpers
extension ProductScreen {
  private var productInteractor: ProductInteractable {
    return dependencyEnv.interactors.productInteractor
  }
  
  private var reviewsInteractor: ReviewsInteractable {
    return dependencyEnv.interactors.reviewsInteractor
  }
  
  private var subscriptionInteractor: SubscriptionInteractable {
    return dependencyEnv.interactors.subscriptionInteractor
  }
  
  private func syncEnvironment() {
    productEnv.product = product.value
    print("Product env is synced")
  }
  
  private func getUserInReview(id: String) -> User? {
    return reviews.value?.reviews.first { $0.id == id }?.user
  }
  
  /// Add comment in `ReviewsStore` with temporary id.
  /// This will display the comment on the UI even before receoiving a successful api post request.
  private func postTemporaryComment() {
    let userSession = dependencyEnv.appState.userSession
    let user = User(id: userSession.userId,
                    displayName: userSession.displayName,
                    fullName: userSession.fullName,
                    userName: nil,
                    description: nil,
                    profileImage: userSession.profileImage)
    reviewsStore.addTemporaryComment(reviewId: commentEditor.id,
                                     body: commentText,
                                     user: user)
  }
  
  private func clearEditor() {
    commentEditor = .init(kind: .review, id: "", isActive: false)
    commentText = ""
  }
}

// MARK: - API functions
extension ProductScreen {
  func loadInfo() {
    productInteractor.load(id: id, info: $product, store: $stateStore)
  }
  
  func reloadEverything() {
    loadInfo()
    loadReviews(page: 1)
  }
  
  func loadReviews(page: Int) {
    reviewsInteractor.loadReviews(productId: id,
                                  reviewId: reviewId,
                                  page: page,
                                  reviews: $reviews,
                                  store: reviewsStore)
  }
  
  func subscribe(status: Bool) {
    subscriptionInteractor.subscribeToProduct(id: id, status: status, response: $subscription)
  }
  
  func postComment(reviewId: String, body: String) {
    reviewsInteractor.postComment(reviewId: reviewId, body: body, response: $comment)
  }
  
  func updateComment(id: String, body: String) {
    reviewsInteractor.updateComment(id: id, body: body, response: $commentUpdate)
  }
}

//  MARK: - PreferenceKey
struct EditorHeightKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = value + nextValue()
  }
}

struct FooterHeightKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = value + nextValue()
  }
}

//  MARK: - Skeleton Views
extension ProductScreen {
  private var headerSkeleton: some View {
    HStack {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .frame(width: 94, height: 94)
      Spacer(minLength: 20)
      VStack(alignment: .leading) {
        Rectangle()
          .frame(height: 16)
        Rectangle()
          .frame(height: 16)
      }
    }
    .foregroundColor(Color(.secondarySystemBackground))
    .padding(.bottom, 20)
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity)
  }
  
  private var reviewSkeleton: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 20) {
        Circle().frame(width: 36, height: 36)
        VStack(alignment: .leading) {
          Rectangle().frame(width: 230, height: 12)
          Rectangle().frame(width: 170, height: 12)
        }
      }
      Spacer(minLength: 20)
      Rectangle().frame(width: 100, height: 16)
      Rectangle().frame(width: 170, height: 16)
      Rectangle().frame(width: 210, height: 16)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 30)
    .foregroundColor(Color(.secondarySystemBackground))
  }
}

//  MARK: - Preview
struct ProductScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProductScreen(product: Product.seed,
                    reviews: Reviews(reviews: [Review.seed], pagination: nil),
                    footer: .write,
                    showEditor: true)
      
    }
  }
}

