//
//  MockData.swift
//  Dash
//
//  Created by Steffi Tan on 3/14/22.
//

import Foundation

enum MockData: String {
  case product = "Product"
  case review = "Review"
  case comment = "Comment"
  case postComment = "PostCommentResponse"
  case imageSet = "ImageSet"
}

extension MockData {
  func extract() -> Data? {
    return readLocalFile(forName: self.rawValue)
  }
  
  private func readLocalFile(forName name: String) -> Data? {
    do {
      if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
         let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
        return jsonData
      }
    } catch {
      print(error)
    }
    
    return nil
  }
}

extension JSONDecoder {
  static func decodeMockData<T>(_ type: T.Type, mock: MockData) throws -> T where T : Decodable {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(type, from: mock.extract()!)
  }
}
