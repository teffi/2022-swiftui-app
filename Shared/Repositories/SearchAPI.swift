//
//  SearchAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation
import Combine

protocol SearchAPIProtocol: APIService {
  func searchProduct(query: String, page: Int) -> AnyPublisher<Search.Products, Error>
  func searchSuggestions(questionId: String?) -> AnyPublisher<Search.Products, Error>
  func lookUp(url: String) -> AnyPublisher<Search.Lookup, Error>
}

struct SearchAPI: SearchAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func searchProduct(query: String, page: Int) -> AnyPublisher<Search.Products, Error>{
    return send(endpoint: API(token: token,
                              endpoint: .products(query: query, page: page)),
                method: .get)
  }
  
  func searchSuggestions(questionId: String?) -> AnyPublisher<Search.Products, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .suggestions(questionId: questionId)),
                method: .get)
  }
  
  func lookUp(url: String) -> AnyPublisher<Search.Lookup, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .lookup(url: url)),
                method: .get)
  }
  
}

// MARK: - Endpoints
extension SearchAPI {
  enum Endpoint {
    case products(query: String, page: Int)
    case suggestions(questionId: String?)
    case lookup(url: String)
  }
  struct API: APIRequest {
    let token: String
    let endpoint: SearchAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .products(let query, _):
        //      return "/e1a1e33b-5923-491b-840e-8219e40cad46"
        return "/search/products?q=" + query
      case .suggestions(let questionId):
        //      var resource = "/04500eb4-c3ce-43cf-aa49-b080a6d6dbe7"
        var resource = "/search/suggestions"
        if let questionId = questionId {
          resource.append("?question_id=\(questionId)")
        }
        return resource
      case .lookup(let url):
        //return "/7f4d9cec-345e-4bc2-a91b-80674f39d900"
        return "/search/external_url?url=" + url
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
