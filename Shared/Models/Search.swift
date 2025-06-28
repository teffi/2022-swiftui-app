//
//  Search.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation

struct Search { }

extension Search {
  struct Products: Decodable, Equatable {
    let results: [Search.Product]
  }
  
  struct Product: Decodable, Identifiable, Equatable, Hashable {
    let id: String
    let displayName: String
    let image: ImageSet
    var loveCount = 0
    var hateCount = 0
    var reviewCount = 0
    
    static var seed: Product {
      return .init(id: "1231", displayName: "The Inkey List Niacinamide", image: ImageSet.seed, loveCount: 12, hateCount: 12, reviewCount: 24)
    }
  }
  
  struct Lookup: Decodable {
    let preview: Preview?
    let error: String?
    
    struct Preview: Decodable {
      let displayName: String?
      let imageUrl: String?
    }
  }
}
