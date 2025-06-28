//
//  Response.swift
//  Dash
//
//  Created by Steffi Tan on 2/27/22.
//

import Foundation

struct Response: Decodable {
  let error: Response.Error?
  
  struct Error: Decodable {
    let tag: String
    let title: String?
    let message: String?
    let code: Int
    
    private enum CodingKeys: String, CodingKey {
      case error, tag, title, message, code
    }
    
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let errorContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
      tag = try errorContainer.decode(String.self, forKey: .tag)
      code = try container.decode(Int.self, forKey: .code)
      title = try errorContainer.decodeIfPresent(String.self, forKey: .title)
      message = try errorContainer.decodeIfPresent(String.self, forKey: .message)
    }
  }
}


