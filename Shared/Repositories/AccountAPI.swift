//
//  AccountAPI.swift
//  Dash
//
//  Created by Steffi Tan on 3/28/22.
//

import Foundation
import Combine
import SwiftUI

protocol AccountAPIProtocol: APIService {
  func updateMobile(userId: String, body: [String: Any]) -> AnyPublisher<Account.MobileUpdateResponse, Error>
}

struct AccountAPI: AccountAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func updateMobile(userId: String, body: [String : Any]) -> AnyPublisher<Account.MobileUpdateResponse, Error> {
    return send(endpoint: API(token: token, endpoint: .updateMobile(userId: userId, body: body)), method: .put)
  }
}


// MARK: - Endpoints
extension AccountAPI {
  enum Endpoint {
    case updateMobile(userId: String, body: [String: Any])
  }
  
  struct API: APIRequest {
    let token: String?
    let endpoint: AccountAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .updateMobile(let id, _):
        return "/account/" + id
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      switch endpoint {
      case .updateMobile(_, let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      }
    }
  }
}
