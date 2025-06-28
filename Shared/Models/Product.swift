//
//  Product.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
struct Product: Decodable, Identifiable, Equatable {
  let id: String
  let displayName: String
  let image: ImageSet
  var loveCount = 0
  var hateCount = 0
  var reviewCount = 0
  let user: User?
  let hasSubscribed: Bool
  let hasReviewed: Bool
  let subscribers: Feed.Subscriptions.Summary?
  
  private enum CodingKeys: String, CodingKey {
    case product, id, displayName, image, loveCount, hateCount, reviewCount, user, hasReviewed, hasSubscribed, subscribers
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    subscribers = try container.decodeIfPresent(Feed.Subscriptions.Summary.self, forKey: .subscribers)
    
    let product = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .product)
    id = try product.decode(String.self, forKey: .id)
    displayName = try product.decode(String.self, forKey: .displayName)
    image = try product.decode(ImageSet.self, forKey: .image)
    loveCount = try product.decodeIfPresent(Int.self, forKey: .loveCount) ?? 0
    hateCount = try product.decodeIfPresent(Int.self, forKey: .hateCount) ?? 0
    reviewCount = try product.decodeIfPresent(Int.self, forKey: .reviewCount) ?? 0
    hasReviewed = try product.decodeIfPresent(Bool.self, forKey: .hasReviewed) ?? false
    hasSubscribed = try product.decodeIfPresent(Bool.self, forKey: .hasSubscribed) ?? false
    user = try product.decodeIfPresent(User.self, forKey: .user)
  }
}
