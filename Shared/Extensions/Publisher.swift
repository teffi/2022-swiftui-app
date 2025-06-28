//
//  Publisher.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import Combine

extension Publisher {
  func extractUnderlyingError() -> Publishers.MapError<Self, Failure> {
    mapError {
      ($0.underlyingError as? Failure) ?? $0
    }
  }
  
  /// Sink that wraps data in `Result`
  /// - Parameter result:
  /// - Returns:
  func sinkToResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
    return sink(receiveCompletion: { completion in
      switch completion {
      case let .failure(error):
        result(.failure(error))
      default: break
      }
    }, receiveValue: { value in
      result(.success(value))
    })
  }
  
  /// Sink that wraps result in Loadable
  /// - Parameter completion: `Loadable` closure
  /// - Returns:
  func sinkToLoadable(_ completion: @escaping (Loadable<Output>) -> Void) -> AnyCancellable {
    return sink(receiveCompletion: { subscriptionCompletion in
      if let error = subscriptionCompletion.error {
        completion(.failed(error))
      }
    }, receiveValue: { value in
      completion(.loaded(value))
    })
  }
}

private extension Error {
  var underlyingError: Error? {
    let nsError = self as NSError
    if nsError.domain == NSURLErrorDomain && nsError.code == -1009 {
      // "The Internet connection appears to be offline."
      return self
    }
    return nsError.userInfo[NSUnderlyingErrorKey] as? Error
  }
}

extension Subscribers.Completion {
  var error: Failure? {
    switch self {
    case let .failure(error): return error
    default: return nil
    }
  }
}

