//
//  DependencyInjector.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import SwiftUI
import Combine

// MARK: - DIContainer
//  Dependency Injector Container Environment
struct DIContainer: EnvironmentKey {
  let appState: AppState
  let interactors: Interactors
  
  init(appState: AppState, interactors: Interactors) {
    print("init dicontainer")
    self.appState = appState
    self.interactors = interactors
  }

  //  Use stub for default value
  static var defaultValue: Self { Self.default }
  private static let `default` = Self(appState: AppState(), interactors: .stub)
}

extension EnvironmentValues {
  var injected: DIContainer {
    get { self[DIContainer.self] }
    set { self[DIContainer.self] = newValue }
  }
}

// MARK: - Dependency Injection Container preview stub
//#if DEBUG
extension DIContainer {
  static var preview: Self {
    .init(appState: AppState(), interactors: .stub)
  }
}
//#endif

// MARK: - API repositories
extension DIContainer {
  /// Collection of all apis
  struct APIRespositories {
    let product: ProductAPI
    let reviews: ReviewsAPI
    let search: SearchAPI
    let feed: FeedAPI
    let profile: ProfileAPI
    let auth: AuthAPI
    let notifications: NotificationsAPI
    let account: AccountAPI
    let report: ReportAPI
  }
}

// MARK: - Injection in the ui layer
extension View {
  /// Inject `DIContainer` as environment
  /// - Parameter container: `DIContainer`
  /// - Returns:
  func inject(_ container: DIContainer) -> some View {
    return self
      .environment(\.injected, container)
  }
}
