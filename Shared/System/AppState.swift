//
//  AppState.swift
//  Dash
//
//  Created by Steffi Tan on 2/22/22.
//

import SwiftUI

class AppState: ObservableObject, Equatable {
  @Published var userSession = UserSession.noSession
  @Published var routing = ViewRouting()
  
  /// Returns true if app has a stored user id and token.
  var isUserLoggedIn: Bool {
    return !userSession.userId.isEmpty && !userSession.token.isEmpty
  }
  
  init() {
    startup()
  }
  
  private func startup() {
    if let session = DefaultStore.decode(key: .user_session, type: UserSession.self) {
      userSession = session
    } else {
      userSession = UserSession.noSession
    }
    
    //  Change root to .tab when there's no user and token.
    if isUserLoggedIn {
      routing.root = .tab
    }
  }
  
  static func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userSession.token == rhs.userSession.token
  }

  func updateSession(_ value: UserSession) {
    //  Update
    userSession = value
    
    //  Save to persist
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(value)
      DefaultStore.save(.user_session, value: data)
    } catch {
      print("Unable to Encode user session (\(error))")
    }
  }
  
  func removeUserSession() {
    DefaultStore.remove(.user_session)
  }
  
  func showAlert(title: String?, message: String?) {
    routing.showAlert = true
    routing.alertTitle = title
    routing.alertMessage = message
  }
  
  func clearAlert() {
    routing.showAlert = false
    routing.alertMessage = nil
    routing.alertTitle = nil
  }
}

//  MARK: - User Session
extension AppState {
  struct UserSession: Codable {
    var token: String
    var userId: String
    var displayName: String
    var fullName: String
    var profileImage: ImageSet?
    
    static var noSession: UserSession {
      return UserSession(token: "",
                         userId: "",
                         displayName: "",
                         fullName: "",
                         profileImage: nil)
    }
  }
}

//  MARK: - Routing

extension AppState {
  func updateRoot(_ root: AppState.ViewRouting.Root) {
    routing.root = root
  }
  
  func routeEntryTo(_ route: EntryRouteDestination) {
    routing.entry = route
  }
}

extension AppState {
  typealias AppRoot = AppState.ViewRouting.Root
  typealias EntryRouteDestination = AppState.ViewRouting.EntryRoute
  
  struct ViewRouting: Equatable {
    //  MARK: - Root (Window)
    enum Root {
      case entry, tab
    }
    var root: Root = .entry
    
    //  MARK: - Entry
    enum EntryRoute: Hashable {
      case login, signup, `self`
    }
    var entry: EntryRoute? = .`self`
    
    //  Alerts
    var showAlert = false
    var alertTitle: String? = ""
    var alertMessage: String? = ""    
  }
}
