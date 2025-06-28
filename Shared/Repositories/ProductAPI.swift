//
//  ProductAPI.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import Combine

protocol ProductAPIProtocol: APIService {
  func getProduct(id: String) -> AnyPublisher<Product, Error>
  func createProduct(body: [String: Any]) -> AnyPublisher<Product, Error>
}

struct ProductAPI: ProductAPIProtocol {
  let session: URLSession
  let baseUrl: String
  let token: String
  
  init(session: URLSession, baseUrl: String, token: String) {
    self.session = session
    self.baseUrl = baseUrl
    self.token = token
  }
  
  func getProduct(id: String) -> AnyPublisher<Product, Error> {

    return send(endpoint: API(token: token,
                              endpoint: .product(id: id)),
                method: .get)
  }
  
  func createProduct(body: [String : Any]) -> AnyPublisher<Product, Error> {
    return send(endpoint: API(token: token,
                              endpoint: .newProduct(body: body)),
                method: .post)
  }
}

// MARK: - Endpoints
extension ProductAPI {
  enum Endpoint {
    case product(id: String)
    case newProduct(body: [String: Any])
  }
  struct API: APIRequest {
    let token: String?
    let endpoint: ProductAPI.Endpoint
    
    var path: String {
      switch endpoint {
      case .product(let id):
        return "/products/" + id
        //return "/d22d293d-3ffc-4ff0-8381-1fcfd285d342"
      case .newProduct:
        return "/products"
        //return "/d22d293d-3ffc-4ff0-8381-1fcfd285d342"
      }
    }
    
    var headers: [String: String]? {
      return createTokenHeader(token)
    }
    
    func body() throws -> Data? {
      switch endpoint {
      case .newProduct(let rawBody):
        return try? JSONSerialization.data(withJSONObject: rawBody, options: [])
      default:
        return nil
      }
    }
  }
}

