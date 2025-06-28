//
//  AppInfo.swift
//  Dash
//
//  Created by Steffi Tan on 3/31/22.
//

import Foundation

struct AppInfo {
  static var version: String {
    return AppInfo.read(key: "CFBundleShortVersionString")
  }
  
  static var build: String {
    return AppInfo.read(key: "CFBundleVersion")
  }
  
  static var bundleIdentifier: String {
    return AppInfo.read(key: "CFBundleIdentifier")
  }
  
  static var platform: String {
    return "ios"
  }
  
  /// Retrieves and returns associated values (of Type String) from info.Plist of the app.
  fileprivate static func read(key: String) -> String {
    let infoPlist = Bundle.main.infoDictionary
    if let value = infoPlist?[key] as? String {
      return value
    }
    assertionFailure("AppInfo: Trying to retrieve an unknown info - \(key)")
    return "unknown"
  }
}
