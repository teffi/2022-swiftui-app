//
//  Seed.swift
//  Dash
//
//  Created by Steffi Tan on 3/15/22.
//
import Foundation

/// Seed for models
protocol Seedable {
  static var seed: Self { get }
}

//  MARK: - Product
extension Product: Seedable {
  static var seed: Product {
    return try! JSONDecoder.decodeMockData(Product.self, mock: .product)
  }
}

//  MARK: - Review
extension Review: Seedable {
  static var seed: Review {
    return try! JSONDecoder.decodeMockData(Review.self, mock: .review)
  }
}

//  MARK: - Comment
extension Comment: Seedable {
  static var seed: Comment {
    return try! JSONDecoder.decodeMockData(Comment.self, mock: .comment)
  }
}

extension Review.PostComment: Seedable {
  static var seed: Review.PostComment {
    return try! JSONDecoder.decodeMockData(Review.PostComment.self, mock: .postComment)
  }
}

//  MARK: - Imageset
extension ImageSet: Seedable {
  static var seed: ImageSet {
    return try! JSONDecoder.decodeMockData(ImageSet.self, mock: .imageSet)
  }
}

