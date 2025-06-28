//
//  FeedAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation
import Combine
import SwiftUI

protocol FeedAPIProtocol: APIService {
  func load(timestamp: String?, mode: String?) -> AnyPublisher<Feed, Error>
  func checkAppUpdate() -> AnyPublisher<AppUpdate, Error>
}

struct FeedAPI: FeedAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String

  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }

  func load(timestamp: String? = nil, mode: String? = nil) -> AnyPublisher<Feed, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .index(timestamp: timestamp, mode: mode)),
                method: .get)
  }
  
  func checkAppUpdate() -> AnyPublisher<AppUpdate, Error> {
    return send(endpoint: API(token: token, endpoint: .appUpdate),
                method: .get)
  }
}

// MARK: - Endpoints
extension FeedAPI {
  enum Endpoint {
    case index(timestamp: String?, mode: String?)
    case appUpdate
  }
  
  struct API: APIRequest {
    let token: String?
    let endpoint: FeedAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .index(let timestamp, let mode):
        var components = URLComponents()
        var items: [URLQueryItem] = []
        
        if let timestamp = timestamp {
          items.append(URLQueryItem(name: "timestamp", value: timestamp))
        }
        if let mode = mode {
          items.append(URLQueryItem(name: "mode", value: mode))
        }
        components.queryItems = items
        return "/feed" + (components.string ?? "")
      
      case .appUpdate:
        return "/app"
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      return nil
    }
  }
}
