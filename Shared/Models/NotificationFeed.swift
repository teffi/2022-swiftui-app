//
//  NotificationFeed.swift
//  Dash
//
//  Created by Steffi Tan on 3/26/22.
//

import Foundation

struct NotificationFeed: Decodable {
  let notifications: [NotificationFeed.Item]
  var pagination: Pagination?
}

extension NotificationFeed {
  enum ObjectType: String {
    case review
    case comment
    case like
    case unsupported
  }
  
  struct Item: Decodable, Identifiable {
    typealias Summary = Feed.Subscriptions.Summary
    let id: String
    let sourceId: String
    let objectType: ObjectType
    let productId: String?
    let reviewId: String?
    let previewText: String?
    let timeSince: String?
    let iconImageUrl: String?
    let productImage: ImageSet?
    let summary: Summary
    
    private enum CodingKeys: String, CodingKey {
      case id, sourceId, sourceType, reviewId, productId, previewText, timeSince, iconImageUrl, productImage, summary
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)      
      id = try container.decode(String.self, forKey: .id)
      sourceId = try container.decode(String.self, forKey: .sourceId)
      let objectTypeInString = try container.decode(String.self, forKey: .sourceType)
      objectType = ObjectType(rawValue: objectTypeInString) ?? .unsupported
      reviewId = try container.decodeIfPresent(String.self, forKey: .reviewId)
      productId = try container.decodeIfPresent(String.self, forKey: .productId)
      previewText = try container.decode(String.self, forKey: .previewText)
      timeSince = try container.decodeIfPresent(String.self, forKey: .timeSince)
      iconImageUrl = try container.decodeIfPresent(String.self, forKey: .iconImageUrl)
      productImage = try container.decodeIfPresent(ImageSet.self, forKey: .productImage)
      summary = try container.decode(Summary.self, forKey: .summary)
    }
    
    init() {
      id = "123"
      sourceId = "12"
      objectType = .review
      reviewId = "10"
      productId = "1234"
      previewText = "Totally agree about leaving some water on the face before moisturizer. Has helped my dryness tremendously."
      timeSince = "1 hour ago"
      iconImageUrl = "https://image.similarpng.com/very-thumbnail/2021/06/Green-check-mark-icon-on-transparent-background-PNG.png"
      productImage = ImageSet.seed
      summary = Summary(displayText: "**Elizabeth** reviewed a product", users: [User.seed])
    }
  }
  
  struct State: Decodable, Equatable {
    let hasNewNotifications: Bool
  }
}

