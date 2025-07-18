//
//  Loadable.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//


import Foundation
import SwiftUI

typealias LoadableSubject<Value> = Binding<Loadable<Value>>

enum Loadable<T> {
  //  For when there's no data or nothing is in progress
  case idle
  //  For when there's a loading in progress.
  case isLoading(last: T?, cancelBag: CancelBag)
  //  For when value is loaded
  case loaded(T)
  //  For when loading fails
  case failed(Error)
  
  var value: T? {
    switch self {
    case let .loaded(value): return value
    case let .isLoading(last, _): return last
    default: return nil
    }
  }
  
  var isLoading: Bool {
    switch self {
    case .loaded: return false
    case .isLoading: return true
    default: return false
    }
  }
    
  var error: Error? {
    switch self {
    case let .failed(error): return error
    default: return nil
    }
  }
}

extension Loadable {
  
  mutating func setIsLoading(cancelBag: CancelBag) {
    self = .isLoading(last: value, cancelBag: cancelBag)
  }
  
  mutating func cancelLoading() {
    switch self {
    case let .isLoading(last, cancelBag):
      cancelBag.cancel()
      if let last = last {
        self = .loaded(last)
      } else {
        let error = NSError(
          domain: NSCocoaErrorDomain, code: NSUserCancelledError,
          userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Canceled by user",
                                                                  comment: "")])
        self = .failed(error)
      }
    default: break
    }
  }
  
  func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
    do {
      switch self {
      case .idle: return .idle
      case let .failed(error): return .failed(error)
      case let .isLoading(value, cancelBag):
        return .isLoading(last: try value.map { try transform($0) },
                          cancelBag: cancelBag)
      case let .loaded(value):
        return .loaded(try transform(value))
      }
    } catch {
      return .failed(error)
    }
  }
}

protocol SomeOptional {
  associatedtype Wrapped
  func unwrap() throws -> Wrapped
}

struct ValueIsMissingError: Error {
  var localizedDescription: String {
    NSLocalizedString("Data is missing", comment: "")
  }
}

extension Optional: SomeOptional {
  func unwrap() throws -> Wrapped {
    switch self {
    case let .some(value): return value
    case .none: throw ValueIsMissingError()
    }
  }
}

extension Loadable where T: SomeOptional {
  func unwrap() -> Loadable<T.Wrapped> {
    map { try $0.unwrap() }
  }
}

extension Loadable: Equatable where T: Equatable {
  static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle): return true
    case let (.isLoading(lhsV, _), .isLoading(rhsV, _)): return lhsV == rhsV
    case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
    case let (.failed(lhsE), .failed(rhsE)):
      return lhsE.localizedDescription == rhsE.localizedDescription
    default: return false
    }
  }
}

