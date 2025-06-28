//
//  AuthAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/23/22.
//

import Foundation
import Combine

protocol AuthAPIProtocol: APIService {
  func verifyInviteCode(body: [String: Any]) -> AnyPublisher<Response, Error>
  func requestOTP(body: [String: Any]) -> AnyPublisher<Auth.OTP, Error>
  func verifyOTP(body: [String: Any]) -> AnyPublisher<Auth.Verification, Error>
  func verifySignInWithApple(body: [String: Any]) -> AnyPublisher<Auth.Verification, Error>
}

struct AuthAPI: AuthAPIProtocol {
  let session: URLSession
  let baseUrl: String
  
  init(session: URLSession, baseUrl: String) {
    self.session = session
    self.baseUrl = baseUrl
  }
  
  func verifyInviteCode(body: [String: Any]) -> AnyPublisher<Response, Error> {
    return send(endpoint: API.verifyInvite(body: body), method: .post)
  }
  
  func requestOTP(body: [String : Any]) -> AnyPublisher<Auth.OTP, Error> {
    return send(endpoint: API.requestOTP(body: body), method: .post)
  }
  
  func verifyOTP(body: [String : Any]) -> AnyPublisher<Auth.Verification, Error> {
    return send(endpoint: API.verifyOTP(body: body), method: .post)
  }
  
  func verifySignInWithApple(body: [String : Any]) -> AnyPublisher<Auth.Verification, Error> {
    return send(endpoint: API.verifySignInWithApple(body: body), method: .post)
  }
}

// MARK: - Endpoints

extension AuthAPI {
  enum API {
    case verifyInvite(body: [String: Any])
    case requestOTP(body: [String: Any])
    case verifyOTP(body: [String: Any])
    case verifySignInWithApple(body: [String: Any])
  }
}

extension AuthAPI.API: APIRequest {
  var path: String {
    switch self {
    case .verifyInvite(_):
      return "/auth/invite/verify_code"
    case .requestOTP(_):
      return "/auth/otp/request_code"
    case .verifyOTP(_):
      return "/auth/otp/login"
    case .verifySignInWithApple(_):
      return "/auth/apple/login"
    }
  }
  
  var headers: [String: String]? {
    return nil // ["Authorization": "Token \(UUID().uuidString)"]
  }
  
  func body() throws -> Data? {
    switch self {
    case .verifyInvite(let rawBody):
      return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
    case .requestOTP(let rawBody):
      return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
    case .verifyOTP(let rawBody):
      return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
    case .verifySignInWithApple(let rawBody):
      return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
    }
  }
}
