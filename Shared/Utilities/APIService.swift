//
//  APIService.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import Combine

protocol APIService {
  var session: URLSession { get }
  var baseUrl: String { get }
}

extension APIService {
  func send<Value>(endpoint: APIRequest, method: HTTPMethod, httpCodes: HTTPCodes = .success) -> AnyPublisher<Value, Error> where Value: Decodable {
    do {
      let request = try endpoint.urlRequest(baseUrl: baseUrl, method: method)
      return session
        .dataTaskPublisher(for: request)
        .requestJSON(httpCodes: httpCodes)
    } catch let error {
      return Fail<Value, Error>(error: error).eraseToAnyPublisher()
    }
  }
}

// MARK: - Helpers

private extension Publisher where Output == URLSession.DataTaskPublisher.Output {
  func requestJSON<Value>(httpCodes: HTTPCodes) -> AnyPublisher<Value, Error> where Value: Decodable {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return tryMap { data, response in
      assert(!Thread.isMainThread)
      guard let code = (response as? HTTPURLResponse)?.statusCode else {
        throw APIError.unexpectedResponse
      }
      guard httpCodes.contains(code) else {
        if code == 500 {
          throw APIError.internalServer
        } else {
          // Decode error object from unsuccessful request
          let errorModel = try decoder.decode(Response.Error.self, from: data)
          throw APIError.httpCode(code, error: errorModel)
        }
      }
      return data
    }
    .extractUnderlyingError()
    .decode(type: Value.self, decoder: decoder)
    .receive(on: DispatchQueue.main)
//    #if DEBUG
//    .print("Session Pub")
//    #endif
    .eraseToAnyPublisher()
  }
}
