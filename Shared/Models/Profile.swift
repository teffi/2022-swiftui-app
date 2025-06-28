//
//  Profile.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import Foundation

struct Profile: Decodable {
  let user: User.Profile
  
  static var seed: Profile {
    .init(user: User.Profile.seed)
  }
}

// MARK: - Sub models
extension Profile {
  
  struct ProductActivities: Decodable {
    let products: [Product]
    let pagination: Pagination?
  }
  
  struct Product: Decodable, Identifiable, Hashable {
    let id: String
    let reviewId: String
    let image: ImageSet
    let kind: String
  }
  
  struct Interests: Decodable {
    let interests: [Interest]
  }
}

struct Interest: Decodable, Identifiable {
  let id: String
  let name: String
  let items: [Interest.Item]
  
  struct Item: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
  }
}
