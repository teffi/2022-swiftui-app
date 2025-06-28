//
//  Comment.swift
//  Dash
//
//  Created by Steffi Tan on 3/17/22.
//

import Foundation

//  General comment model.
struct Comment: Decodable, Hashable, Identifiable {
  static var TEMPORARY_COMMENT_ID_PREFIX = "temporary_comment_"
  
  let id: String
  var body: String
  let user: User
  
  /// Returns true if id matches the temporary comment naming
  var isTemporary: Bool {
    return id.contains(Comment.TEMPORARY_COMMENT_ID_PREFIX)
  }
  
  init(id: String, body: String, user: User) {
    self.id = id
    self.body = body
    self.user = user
  }
  
  init(body: String, user: User) {
    let tempId = Comment.TEMPORARY_COMMENT_ID_PREFIX + UUID().uuidString
    self.id = tempId
    self.body = body
    self.user = user
  }
  
  struct Review: Decodable {
    let id: String
    let body: String
    let kind: String
    let user: User
    let shareableUrl: String?
  }
}

extension Review {
  //  Comment model with review property.
  struct PostComment: Decodable {
    let id: String
    let body: String
    let user: User
    let review: Comment.Review
    
    private enum CodingKeys: String, CodingKey {
      case comment, id, body, user, review
    }
        
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let comment = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .comment)
      id = try comment.decode(String.self, forKey: .id)
      body = try comment.decode(String.self, forKey: .body)
      user = try comment.decode(User.self, forKey: .user)
      review = try comment.decode(Comment.Review.self, forKey: .review)
    }
  }
}
