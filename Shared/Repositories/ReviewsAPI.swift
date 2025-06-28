//
//  ReviewsAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import Combine

protocol ReviewsAPIProtocol: APIService {
  func getProductReviews(id: String, reviewId: String?, page: Int) -> AnyPublisher<Reviews, Error>
  func postProductReview(body: [String: Any]) -> AnyPublisher<Review.PostResponse, Error>
  func updateProductReview(id: String, body: [String: Any]) -> AnyPublisher<Review.PostResponse, Error>
  func deleteProductReview(id: String) -> AnyPublisher<Response, Error>
  func likeReview(reviewId: String, body: [String: Any]) -> AnyPublisher<Response, Error>
  func postComment(reviewId: String, body: [String: Any]) -> AnyPublisher<Review.PostComment, Error>
  func updateComment(id: String, body: [String: Any]) -> AnyPublisher<Review.PostComment, Error>
  func deleteComment(id: String) -> AnyPublisher<Response, Error>
}

struct ReviewsAPI: ReviewsAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func getProductReviews(id: String, reviewId: String? = nil, page: Int) -> AnyPublisher<Reviews, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .product(id: id, reviewId: reviewId, page: page)),
                method: .get)
  }
  
  func postProductReview(body: [String : Any]) -> AnyPublisher<Review.PostResponse, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .postReview(body: body)),
                method: .post)
  }
  
  func updateProductReview(id: String, body: [String : Any]) -> AnyPublisher<Review.PostResponse, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .updateReview(id: id, body: body)),
                method: .put)
  }
  
  func deleteProductReview(id: String) -> AnyPublisher<Response, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .deleteReview(id: id)),
                method: .delete)
  }
  
  func likeReview(reviewId: String, body: [String : Any]) -> AnyPublisher<Response, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .like(id: reviewId, body: body)),
                method: .post)
  }
  
  func postComment(reviewId: String, body: [String : Any]) -> AnyPublisher<Review.PostComment, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .postComment(reviewId: reviewId, body: body)),
                method: .post)
  }
  
  func updateComment(id: String, body: [String : Any]) -> AnyPublisher<Review.PostComment, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .updateComment(id: id, body: body)),
                method: .put)
  }
  
  func deleteComment(id: String) -> AnyPublisher<Response, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .deleteComment(id: id)),
                method: .delete)
  }
}

// MARK: - Endpoints

extension ReviewsAPI {
  enum Endpoint {
    case product(id: String, reviewId: String?, page: Int)
    case postReview(body: [String: Any])
    case updateReview(id: String, body: [String: Any])
    case deleteReview(id: String)
    case like(id: String, body: [String: Any])
    case postComment(reviewId: String, body: [String: Any])
    case updateComment(id: String, body: [String: Any])
    case deleteComment(id: String)
  }
  
  struct API: APIRequest {
    let token: String
    let endpoint: ReviewsAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .product(let id, let reviewId, let page):
        var components = URLComponents()
        var items: [URLQueryItem] = [URLQueryItem(name: "object_id", value: id),
                                     URLQueryItem(name: "object_type", value: "Product"),
                                     URLQueryItem(name: "page", value: String(page))]
        if let reviewId = reviewId {
          items.append(URLQueryItem(name: "review_id", value: reviewId))
        }
        components.queryItems = items
        return "/reviews" + (components.string ?? "")
      case .postReview:
        return "/reviews"
      case .updateReview(let id, _):
        return "/reviews/" + id
      case .deleteReview(let id):
        return "/reviews/" + id
      case .like:
        return "/likes"
      case .postComment:
        return "/comments"
      case .updateComment(let id, _):
        return "/comments/" + id
      case .deleteComment(let id):
        return "/comments/" + id
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      switch endpoint {
      case .postReview(let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      case .updateReview(_, let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      case .like(_, let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      case .postComment(_, let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      case .updateComment(_, let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      default:
        return nil
      }
    }
  }
}
