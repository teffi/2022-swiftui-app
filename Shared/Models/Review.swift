//
//  Review.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation

struct Reviews: Decodable  {
  let reviews: [Review]
  let pagination: Pagination?
}

struct Review: Decodable, Identifiable, Hashable {
  let id: String
  let body: String
  let kind: String
  var likeCount: Int
  var commentCount: Int
  var isHighlighted: Bool = false
  let user: User
  var comments: [Comment]?
  var product: Review.Product? = nil
  let hasLiked: Bool
  let shareableUrl: String?
  var images: [ImageSet]?
  var thumbnailImageUrls: [String] {
    return images?.compactMap { $0.mediumUrl } ?? []
  }
}

// MARK: - Sub models
extension Review {
  //   Product information
  struct Product: Decodable, Identifiable, Equatable, Hashable {
    let id: String
    let displayName: String
    var image: ImageSet
    var loveCount = 0
    var hateCount = 0
    var reviewCount = 0
    let user: User?
  }
  
  //   Post review response
  struct PostResponse: Decodable {
    let review: PostResponse.Review
    let question: FeedQuestion?
    
    struct Review: Decodable {
      let id: String
      let body: String
      let kind: String
      let createdAt: String
    }
  }
}

struct Pagination: Decodable {
  var current: Int
  var total: Int
  
  private enum CodingKeys: String, CodingKey {
    case currentPage, totalPages
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    current = try container.decode(Int.self, forKey: .currentPage)
    total = try container.decode(Int.self, forKey: .totalPages)
  }
  
  init() {
    current = 1
    total = 1
  }
}


// MARK: - PicsumUnique Wrapper
@propertyWrapper
struct PicsumUnique: Codable, Equatable, Hashable {
  var wrappedValue: String?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(String.self) {
      wrappedValue = value + "?q=" + UUID().uuidString
    }
    else {
      // Default...
      wrappedValue = " "
    }
  }
  init() {
    wrappedValue = "https://picsum.photos/400/500"
  }
}
