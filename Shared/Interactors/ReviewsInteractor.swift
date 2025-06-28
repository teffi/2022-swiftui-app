//
//  ReviewsInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
//  MARK: - State store
class ReviewsStore: ObservableObject {
  @Published var reviews: [Review] = []
  @Published var forms: [ProductReviewForm] = []
  @Published var pagination = Pagination()
  @Published var shouldLoadMore = false
  private let loadMoreOffset = 1
  
  var hasNextPage: Bool {
    return nextPage != nil
  }
  
  var nextPage: Int? {
    guard pagination.current < pagination.total else { return nil }
    return pagination.current + 1
  }

  func isLastReview(_ review: Review) -> Bool {
    guard let lastReview = reviews.last else { return false }
    return review.id == lastReview.id
  }
  
  func isFirstReview(_ review: Review) -> Bool {
    guard let firstReview = reviews.first else { return false }
    return review.id == firstReview.id
  }
  
  /// Append reviews
  /// - Parameter newReviews:
  func addReviews(_ newReviews: [Review]) {
    reviews.append(contentsOf: newReviews)
  }
  
  /// Append comment with temporary id.
  /// - Parameters:
  ///   - reviewId:
  ///   - body:
  ///   - user:
  func addTemporaryComment(reviewId: String, body: String, user: User) {
    if let reviewIndex = reviews.firstIndex(where: { $0.id == reviewId }) {
      var reviewWithNewComment = reviews[reviewIndex]
      //  Make sure that comments is not nil.
      if reviewWithNewComment.comments == nil {
        reviewWithNewComment.comments = []
      }
      reviewWithNewComment.comments?.append(.init(body: body, user: user))
      //  Important: Replace review with the mutated copy in the main datasource.
      reviews[reviewIndex] = reviewWithNewComment
    }
  }
  
  /// Replace reviews
  /// - Parameter reviews:
  func updateReviews(_ reviews: [Review]) {
    self.reviews = reviews
    self.forms = reviews.map { .init(review: $0) }
  }
  
  func getFormOfReview(id: String) -> ProductReviewForm {
    return forms.first { $0.reviewId == id } ??  ProductReviewForm()
  }
  
  /// Searches through the list of comments and update its data.
  /// - Important:
  ///   - Because of the temporary id we generate, item matching is based on `user.id` and `body` and NOT `id`
  /// - Warning:
  ///   - Best used for updating a comment with temporary id. If updating a non-temporary comment, use `updateComment(reviewId: String, comment: Comment)`
  /// - Parameters:
  ///   - reviewId: review id of the comment
  ///   - comment: comment data with temporary id
  func updateTemporaryComment(reviewId: String, comment: Comment) {
    //  TODO: Find a better  identifier to use instead of matching comment user id and body when comparing comment data from server and app local
    //  - Ideas: Hashing username and body?
    if let reviewIndex = reviews.firstIndex(where: { $0.id == reviewId }),
       let commentIndex = reviews[reviewIndex].comments?.firstIndex(where: { $0.user.id == comment.user.id && $0.body == comment.body }){
      print("before update review comments: \( String(describing: reviews[reviewIndex].comments?.map { $0.id }))")
      var reviewComments = reviews[reviewIndex].comments
      let commentCount = reviews[reviewIndex].commentCount
      reviewComments?[commentIndex] = comment
      reviews[reviewIndex].comments = reviewComments
      reviews[reviewIndex].commentCount = commentCount + 1
      print("update review comments: \( String(describing: reviews[reviewIndex].comments?.map { $0.id }))")
    }
  }
  
  /// Search comment from reviews and update body
  /// - Parameters:
  ///   - reviewId:
  ///   - commentId:
  ///   - body:
  func saveEditedComment(reviewId: String, commentId: String, body: String) {
    if let reviewIndex = reviews.firstIndex(where: { $0.id == reviewId }),
       let commentIndex = reviews[reviewIndex].comments?.firstIndex(where: { $0.id == commentId}){
      var reviewComments = reviews[reviewIndex].comments
      reviewComments?[commentIndex].body = body
      reviews[reviewIndex].comments = reviewComments
      print("save edited comments: \( String(describing: reviews[reviewIndex].comments?.map { $0.id }))")
    }
  }
  
  /// Searches through the list of comments and update comment data.
  /// - Important:
  ///   - Item matching is based on `id`
  /// - Parameters:
  ///   - reviewId: review id of the comment
  ///   - comment:
  func updateComment(reviewId: String, comment: Comment) {
    if let reviewIndex = reviews.firstIndex(where: { $0.id == reviewId }),
       let commentIndex = reviews[reviewIndex].comments?.firstIndex(where: { $0.id == comment.id }){
      var reviewComments = reviews[reviewIndex].comments
      reviewComments?[commentIndex] = comment
      reviews[reviewIndex].comments = reviewComments
    }
  }
}
//  MARK: - Store load more
extension ReviewsStore {
  func loadMoreIfNeeded(current review: Review) {
    guard hasNextPage else { return }
    let thresholdIndex = reviews.index(reviews.endIndex, offsetBy: -loadMoreOffset)
    if reviews.firstIndex(where: { $0.id == review.id }) == thresholdIndex {
      shouldLoadMore = true
    }
  }
}

//  MARK: - Interactor
protocol ReviewsInteractable {
  //  Reviews
  func loadReviews(productId: String,
                   reviewId: String?,
                   page: Int,
                   reviews: LoadableSubject<Reviews>,
                   store: ReviewsStore)
  func postReview(productId: String, body: String, kind: String, questionId: String?, imageUrls: [String]?, response: LoadableSubject<Review.PostResponse>)
  func updateReview(id: String, body: String, kind: String, imageUrls: [String]?, response: LoadableSubject<Review.PostResponse>)
  func deleteReview(id: String, response: LoadableSubject<Response>)
  func likeReview(reviewId: String, status: Bool, response: LoadableSubject<Response>)
  //  Comments
  func postComment(reviewId: String, body: String, response: LoadableSubject<Review.PostComment>)
  func updateComment(id: String, body: String, response: LoadableSubject<Review.PostComment>)
  func deleteComment(id: String, response: LoadableSubject<Response>)

}

struct ReviewsInteractor: ReviewsInteractable {
  let api: ReviewsAPI
  
  //  MARK: - Reviews
  func loadReviews(productId: String,
                   reviewId: String? = nil,
                   page: Int,
                   reviews: LoadableSubject<Reviews>,
                   store: ReviewsStore) {
    let cancelBag = CancelBag()
    reviews.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.getProductReviews(id: productId, reviewId: reviewId, page: page)
      .sinkToLoadable { result in
        reviews.wrappedValue = result
        
        if let resultValue = result.value {
          let resultPage = resultValue.pagination?.current ?? 1
          //  We assume that if page is 1, we're starting all over
          if resultPage == 1 {
            store.updateReviews(resultValue.reviews)
          } else {
            store.addReviews(resultValue.reviews)
          }
          
          if let pagination = resultValue.pagination {
            store.pagination = pagination
            print("store page is updated to \(store.pagination)")
          }
        }
      }
      .store(in: cancelBag)
  }
  
  func postReview(productId: String, body: String, kind: String, questionId: String?, imageUrls: [String]?, response: LoadableSubject<Review.PostResponse>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    // Compose body
    var requestBody: [String: Any] = [:]
    requestBody["product_id"] = productId
    requestBody["body"] = body
    requestBody["kind"] = kind
    
    if let questionId = questionId {
      requestBody["question_id"] = questionId
    }
    
    if let imageUrls = imageUrls {
      requestBody["image_urls"] = imageUrls
    }
    
    api.postProductReview(body: requestBody)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func updateReview(id: String, body: String, kind: String, imageUrls: [String]?, response: LoadableSubject<Review.PostResponse>) {
    
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    // Compose body
    var requestBody: [String: Any] = [:]
    requestBody["id"] = id
    requestBody["body"] = body
    requestBody["kind"] = kind

    if let imageUrls = imageUrls {
      requestBody["image_urls"] = imageUrls
    }
    
    api.updateProductReview(id: id, body: requestBody)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)    
  }
  
  func deleteReview(id: String, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.deleteProductReview(id: id)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func likeReview(reviewId: String, status: Bool, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    let requestBody: [String: Any] = ["object_id": reviewId, "like": status, "object_type": "review"]
    api.likeReview(reviewId: reviewId, body: requestBody)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  //  MARK: - Comment
  func postComment(reviewId: String,
                   body: String,
                   response: LoadableSubject<Review.PostComment>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    let requestBody: [String: Any] = ["object_id": reviewId, "body": body, "object_type": "review"]
    api.postComment(reviewId: reviewId, body: requestBody)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func updateComment(id: String, body: String, response: LoadableSubject<Review.PostComment>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    let requestBody: [String: Any] = ["object_id": id, "body": body]
    api.updateComment(id: id, body: requestBody)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func deleteComment(id: String, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.deleteComment(id: id)
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }

}

struct StubReviewsInteractor: ReviewsInteractable {
  func reportReview(id: String, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func reportComment(id: String, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func updateComment(id: String, body: String, response: LoadableSubject<Review.PostComment>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func deleteComment(id: String, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func updateReview(id: String, body: String, kind: String, imageUrls: [String]?, response: LoadableSubject<Review.PostResponse>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func deleteReview(id: String, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func postComment(reviewId: String, body: String, response: LoadableSubject<Review.PostComment>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func likeReview(reviewId: String, status: Bool, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func loadReviews(productId: String, reviewId: String? = nil, page: Int, reviews: LoadableSubject<Reviews>, store: ReviewsStore) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
  
  func postReview(productId: String, body: String, kind: String, questionId: String?, imageUrls: [String]?, response: LoadableSubject<Review.PostResponse>) {
    print("WARNING: Using stub StubReviewsInteractor")
  }
}
//  MARK: - Extension
extension ReviewsInteractable {
  // Function with omitted reviewId
  func loadReviews(productId: String, page: Int, reviews: LoadableSubject<Reviews>) {
    self.loadReviews(productId: productId, reviewId: nil, page: page, reviews: reviews, store: ReviewsStore())
  }
  
  func postReview(productId: String, body: String, kind: String, questionId: String?, response: LoadableSubject<Review.PostResponse>) {
    self.postReview(productId: productId, body: body, kind: kind, questionId: questionId, imageUrls: [], response: response)
  }
  
  func postReview(productId: String, body: String, kind: String, response: LoadableSubject<Review.PostResponse>) {
    self.postReview(productId: productId, body: body, kind: kind, questionId: nil, imageUrls: [], response: response)
  }
}
