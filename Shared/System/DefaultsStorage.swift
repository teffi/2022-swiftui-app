//
//  DefaultsStorage.swift
//  Dash
//
//  Created by Steffi Tan on 2/26/22.
//

import Foundation

typealias DefaultStore = DefaultsStorage

struct DefaultsStorage {
  enum DefaultsKey: String {
    case user_session
    case apple_credentials
  }
  
  static func save(_ key: DefaultsKey, value: Any) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
  }
  
  /// Returns the typecasted value of enum key.
  /// - Parameter type: Data type the receiver expects
  /// - Returns: typecasted value. `nil` if typecasting fails or value is not found in defaults
  static func get<T: Any>(_ key: DefaultsKey, type: T.Type? = nil) -> T?  {
    let keyName = key.rawValue
    switch type {
    case is Bool.Type:
      return UserDefaults.standard.bool(forKey: keyName) as? T
    case is Int.Type:
      return UserDefaults.standard.integer(forKey: keyName) as? T
    case is Float.Type:
      return UserDefaults.standard.float(forKey: keyName) as? T
    case is [String].Type:
      return UserDefaults.standard.stringArray(forKey: keyName) as? T
    case is Data.Type:
      return UserDefaults.standard.data(forKey:keyName) as? T
    default:
      return UserDefaults.standard.string(forKey: keyName) as? T
    }
  }
  
  static func remove(_ key: DefaultsKey) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }
  
  static func decode<T: Decodable>(key: DefaultsKey, type: T.Type) -> T? {
    guard let data = DefaultStore.get(key, type: Data.self) else { return nil }
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(type, from: data)
    } catch {
      print("Unable to decode value for key: \(key), error: (\(error))")
    }
    return nil
  }
  
  //  /// Returns a non-optional typecasted value in closure.
  //  /// Use this to avoid unwrapping of the return value
  //  /// - Parameters:
  //  ///   - type: type: Data type the receiver expects
  //  ///   - completed: Returns a non-optional typecasted value of given key
  //  func get<T: Any>(type: T.Type, completed: (T)->()) {
  //    guard let value = self.get(type: type) else {
  //      return
  //    }
  //    completed(value)
  //  }
  //
  
}
