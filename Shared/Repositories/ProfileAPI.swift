//
//  ProfileAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/18/22.
//

import Foundation
import Combine
import SwiftUI

protocol ProfileAPIProtocol: APIService {
  func get(userId: String) -> AnyPublisher<Profile, Error>
  func getActivities(userId: String, page: Int) -> AnyPublisher<Profile.ProductActivities, Error>
  func updateProfile(userId: String, body: [String: Any]) -> AnyPublisher<Profile, Error>
  func getInterests(userId: String?) -> AnyPublisher<Profile.Interests, Error>
}

struct ProfileAPI: ProfileAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func get(userId: String) -> AnyPublisher<Profile, Error> {
    return send(endpoint: API(token: token, endpoint: .profile(id: userId)), method: .get)
  }
  
  func getActivities(userId: String, page: Int) -> AnyPublisher<Profile.ProductActivities, Error> {
    return send(endpoint: API(token: token, endpoint: .activities(userId: userId, page: page)), method: .get)
  }
  
  func updateProfile(userId: String, body: [String: Any]) -> AnyPublisher<Profile, Error>{
    return send(endpoint: API(token: token, endpoint: .profileUpdate(id: userId, body: body)), method: .put)
  }
  
  func getInterests(userId: String?) -> AnyPublisher<Profile.Interests, Error> {
    return send(endpoint: API(token: token, endpoint: .interests(userId: userId)), method: .get)
  }
}

// MARK: - Endpoints
extension ProfileAPI {
  enum Endpoint {
    case profile(id: String)
    case activities(userId: String, page: Int)
    case profileUpdate(id: String, body: [String: Any])
    case interests(userId: String?)
  }
  
  struct API: APIRequest {
    var token: String?
    let endpoint: ProfileAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .profile(let id):
        return "/profile/" + id
      case .profileUpdate(let id, _):
        return "/profile/" + id
      case .activities(let userId, let page):
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "page", value: String(page))]
        return "/profile/" + userId + "/activities" + (components.string ?? "")
      case .interests(let userId):
        if let uid = userId {
          return "profile/\(uid)/interests"
        }
        return "/interests"
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      switch endpoint {
      case .profileUpdate(_, let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      default:
        return nil
      }
    }
  }
}
