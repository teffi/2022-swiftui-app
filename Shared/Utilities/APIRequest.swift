//
//  APIRequest.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation

//  MARK: - Request
enum HTTPMethod: String {
  case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

protocol APIRequest {
  var path: String { get }
  var client: String  { get }
  var headers: [String: String]? { get }
  func body() throws -> Data?
}

extension APIRequest {
  var client: String  {
    return "ios"
  }
}

extension APIRequest {
  // Merge headers added from APIRequest receivers with defautl headers.
  private var allHeaders: [String: String] {
    let defaultHeaders = ["Content-Type" : "application/json",
                          "Authentication": Credentials.APIAuthenticationKey]
    if let headers = headers {
      return defaultHeaders.merging(headers, uniquingKeysWith: { _, last in last })
    }
    return defaultHeaders
  }
  
  /// Transform path with proper encoding and add query item  `client="ios"`
  private var constructAndEncodePath: String {
    //  IMPT: Encode the current path to sanitize query values with spaces. If left uncoded it fails to preserve the current path which creates an empty urlcomponent.
    var components = URLComponents(string: path.percentEncoded ?? "") ?? URLComponents()
    let queryItems = components.queryItems ?? []
    var newQueryItems: [URLQueryItem] = []
    newQueryItems.append(contentsOf: queryItems)
    newQueryItems.append(URLQueryItem(name: "client", value: client))
    newQueryItems.append(URLQueryItem(name: "app_version", value: AppInfo.version))
    components.queryItems = newQueryItems
    return components.string ?? ""
  }

  func urlRequest(baseUrl: String, method: HTTPMethod) throws -> URLRequest {
    guard let url = URL(string: baseUrl + constructAndEncodePath) else {
      throw APIError.invalidURL
    }
    
    //   Prepare headers  
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = allHeaders
    request.httpBody = try body()
    return request
  }
  
  func createTokenHeader(_ token: String?) -> [String: String]? {
    guard let token = token else { return nil }
    return ["Authorization": "Token \(token)"]
  }
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
  static let success = 200 ..< 300
}

//  MARK: - Error
enum APIError: Swift.Error {
  case invalidURL
  case httpCode(HTTPCode, error: Response.Error?)
  case unexpectedResponse
  case internalServer
  case imageProcessing([URLRequest])
  
  var errorObject: Response.Error? {
    switch self {
    case .httpCode(_, let responseError):
      return responseError
    default:
      return nil
    }
  }
  
  var alert: (title: String, message: String) {
    let unoptionalTitle = errorObject?.title ?? "Uh-oh"
    var completeMessage = self.errorDescription ?? ""
    if let errorObject = errorObject {
      completeMessage =  "\(errorObject.message ?? "") \(errorObject.tag ?? "")"
    }
    return (title: unoptionalTitle, message: completeMessage)
  }
}

extension APIError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidURL: return "Invalid URL"
    case let .httpCode(code, _): return "Unsuccessful HTTP code: \(code)"
    case .unexpectedResponse: return "Unexpected response from the server"
    case .imageProcessing: return "Unable to load image"
    case .internalServer: return "Server error"
    }
  }
}

extension Error {
  var asAPIError: APIError? {
    return self as? APIError
  }
}
