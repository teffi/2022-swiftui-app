//
//  Feed.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation

protocol CardIdentifiable {
  var cardType: Feed.CardType { get set }
}
// MARK: - Feed model typealiases
//  Includes those that are 3 level down
typealias FeedQuestion = Feed.Questions.Question

// MARK: - Feed
struct Feed: Decodable {
  let cards: [Feed.Card]
}

extension Feed {
  enum CardType: String {
    case review
    case subscriptions
    case products
    case users
    case questions
    case unsupported
  }
  
  struct Card: Decodable, Identifiable, Equatable, Hashable {
    let id = UUID().uuidString
    var cardType: Feed.CardType
    var timestamp: String?
    var data: Any
    var dataType: Decodable.Type
    
    private enum CodingKeys: String, CodingKey {
      case cardType, review, title, product, summary, products, questions, timestamp
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let cardTypeRaw = try container.decode(String.self, forKey: .cardType)
      cardType = CardType(rawValue: cardTypeRaw) ?? .unsupported
      timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
      
      let title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
      
      switch cardType {
      case .review:
        data = try container.decode(Review.self, forKey: .review)
        dataType = Review.self
      case .subscriptions:
        let summary = try container.decode(Subscriptions.Summary.self, forKey: .summary)
        let product = try container.decode(Subscriptions.Product.self, forKey: .product)
        data = Subscriptions(title: title,
                             product: product,
                             summary: summary)
        dataType = Subscriptions.self
      case .products:
        let products = try container.decode([Review.Product].self, forKey: .products)
        data = Feed.Products(title: title, products: products)
        dataType = Feed.Products.self
      case .users:
        let summary = try container.decode(Subscriptions.Summary.self, forKey: .summary)
        data = Feed.Users(title: title, summary: summary)
        dataType = Feed.Users.self
      case .questions:
        let questions = try container.decode([Questions.Question].self, forKey: .questions)
        data = Feed.Questions(questions: questions)
        dataType = Feed.Questions.self
      case .unsupported:
        data = UndefinedCard()
        dataType = UndefinedCard.self
      }
    }
    
    //  MARK: - Hashable and Equatable override
    //  https://stackoverflow.com/a/63941509/1045672
    
    static func == (lhs: Feed.Card, rhs: Feed.Card) -> Bool {
      return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
//  MARK: - Subscription Card
  struct Subscriptions: Decodable {
    let title: String
    let product: Product
    let summary: Summary
    
    struct Product: Decodable, Identifiable {
      let id: String
      let displayName: String
      let image: ImageSet?
    }
    
    struct Summary: Decodable, Equatable {
      let displayText: String
      let users: [User]?      
    }
    
    static var seed: Subscriptions {
      return .init(title: "Waiting for review",
                   product: .init(id: "73738", displayName: "COSRX Morning Cleanser", image: ImageSet.seed),
                   summary: .init(displayText: "**Dua**, **Greg**, and **Harvey** are curious about this product.",
                                  users: [User.seed]))
    }
    
  }
  //  MARK: - Users Card
  struct Users: Decodable {
    let title: String
    let summary: Subscriptions.Summary
  }
  
  //  MARK: - Products Card
  struct Products: Decodable {
    let title: String
    let products: [Review.Product]
  }
  
  //  MARK: - QuestionsCard
  struct Questions: Decodable {
    let questions: [Question]
    
    struct Question: Decodable, Identifiable {
      let id: String
      let body: String
      
      static var seed: Question {
        return .init(id: UUID().uuidString, body: "What is your go-to morning cleanser?")
      }
    }
  }

  
  //  MARK: - Wild Card
  /// Wildcard decodable model for unsupported card.
  struct UndefinedCard: Decodable {}
}

