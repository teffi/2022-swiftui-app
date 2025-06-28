//
//  ReportAPI.swift
//  Dash
//
//  Created by Steffi Tan on 3/30/22.
//
import Foundation
import Combine
import SwiftUI

protocol ReportAPIProtocol: APIService {
  func report(body: [String: Any]) -> AnyPublisher<Response, Error>
}

struct ReportAPI: ReportAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func report(body: [String : Any]) -> AnyPublisher<Response, Error> {
    return send(endpoint: API(token: token, endpoint: .report(body: body)), method: .post)
  }
}

// MARK: - Endpoints
extension ReportAPI {
  enum Endpoint {
    case report(body: [String: Any])
  }
  
  struct API: APIRequest {
    let token: String?
    let endpoint: ReportAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .report:
        return "/report"
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      switch endpoint {
      case .report(let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      }
    }
  }
}
