//
//  NotificationsAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/27/22.
//

import Foundation
import Combine
import SwiftUI

protocol NotificationsAPIProtocol: APIService {
  func subscribe(body: [String: Any]) -> AnyPublisher<Response, Error>
  func feed(page: Int) -> AnyPublisher<NotificationFeed, Error>
  func state() -> AnyPublisher<NotificationFeed.State, Error>
}

struct NotificationsAPI: NotificationsAPIProtocol {
  
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func subscribe(body: [String : Any]) -> AnyPublisher<Response, Error> {
    return send(endpoint: API(token: token, endpoint: .notifications(body: body)), method: .post)
  }
  
  func feed(page: Int) -> AnyPublisher<NotificationFeed, Error> {
    return send(endpoint: API(token: token, endpoint: .index(page: page)), method: .get)
  }
  
  func state() -> AnyPublisher<NotificationFeed.State, Error> {
    return send(endpoint: API(token: token, endpoint: .state), method: .get)
  }

}

// MARK: - Endpoints
extension NotificationsAPI {
  enum Endpoint {
    case notifications(body: [String: Any])
    case index(page: Int)
    case state
  }
  
  struct API: APIRequest {
    let token: String?
    let endpoint: NotificationsAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .state:
        return "/notifications/state"
      case .notifications:
        return "/notifications"
      case .index(let page):
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "page", value: String(page))]
        return "/notifications" + (components.string ?? "")
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      switch endpoint {
      case .notifications(let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      default:
        return nil
      }
    }
  }
}
