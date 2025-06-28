//
//  AppEnvironment.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import Sniffer
import SwiftUI

struct AppEnvironment {
  @StateObject var appState: AppState
  
  let container: DIContainer
  
  static func bootstrap(app: StateObject<AppState>) -> AppEnvironment {
    var allowNetworkLogging = false
#if DEBUG
    allowNetworkLogging = true
#endif
    let session = AppSession.configure(enableLogging: allowNetworkLogging)
    let apiRepository = configureAPI(session: session, userData: app.projectedValue.userSession)
    let interactors = configureInteractors(appState: app.wrappedValue, apiRepository: apiRepository)
    let dependencyInjectionContainer = DIContainer(appState: app.wrappedValue, interactors: interactors)
    return AppEnvironment(appState: app.wrappedValue, container: dependencyInjectionContainer)
  }
  
  private static func configureAPI(session: URLSession, userData: Binding<AppState.UserSession>) -> DIContainer.APIRespositories {
    
    let token = userData.wrappedValue.token
    let baseUrl = "https://dash.staging-dash.com/api/v1"
    let productAPI = ProductAPI(session: session,
                                baseUrl: baseUrl,
                                token: token)
    let reviewsAPI = ReviewsAPI(session: session,
                                baseUrl: baseUrl,
                                token: token)
    let searchAPI = SearchAPI(session: session,
                              baseUrl: baseUrl,
                              token: token)
    let feedAPI = FeedAPI(session: session,
                          baseUrl: baseUrl,
                          token: token)
    let profileAPI = ProfileAPI(session: session,
                                baseUrl: baseUrl,
                                token: token)
    let authAPI = AuthAPI(session: session,
                          baseUrl: baseUrl)
    let notificationsAPI = NotificationsAPI(session: session,
                                            baseUrl: baseUrl,
                                            token: token)
    let accountAPI = AccountAPI(session: session,
                                baseUrl: baseUrl,
                                token: token)
    let reportAPI = ReportAPI(session: session,
                              baseUrl: baseUrl,
                              token: token)
    
    return .init(product: productAPI, reviews: reviewsAPI, search: searchAPI, feed: feedAPI, profile: profileAPI, auth: authAPI, notifications: notificationsAPI, account: accountAPI, report: reportAPI)
  }
  
  /// Create all interactors usinga an api repository.
  /// - Parameter api: `DIContainer.APIRespositories`
  /// - Returns: `DIContainer.Interactors` container that holds all interactor
  private static func configureInteractors(appState: AppState, apiRepository: DIContainer.APIRespositories) -> DIContainer.Interactors {
    let productInteractor = ProductInteractor(api: apiRepository.product)
    let reviewsInteractor = ReviewsInteractor(api: apiRepository.reviews)
    let searchInteractor = SearchInteractor(api: apiRepository.search)
    let feedInteractor = FeedInteractor(api: apiRepository.feed)
    let profileInteractor = ProfileInteractor(appState: appState, api: apiRepository.profile)
    let authInteractor = AuthInteractor(appState: appState, api: apiRepository.auth)
    let subscriptionInteractor = SubscriptionInteractor(api: apiRepository.notifications)
    let notificationsInteractor = NotificationsInteractor(api: apiRepository.notifications)
    let accountInteractor = AccountInteractor(api: apiRepository.account)
    let reportInteractor = ReportInteractor(api: apiRepository.report)
    return DIContainer.Interactors(product: productInteractor,
                                   reviews: reviewsInteractor,
                                   search: searchInteractor,
                                   feed: feedInteractor,
                                   profile: profileInteractor,
                                   auth: authInteractor,
                                   subscription: subscriptionInteractor,
                                   notifications: notificationsInteractor,
                                   account: accountInteractor,
                                   report: reportInteractor)
  }
}

extension AppEnvironment {
  struct AppSession {
    fileprivate static func configure(enableLogging: Bool = false) -> URLSession {
      let configuration = URLSessionConfiguration.default
      configuration.timeoutIntervalForRequest = 60
      configuration.timeoutIntervalForResource = 120
      configuration.waitsForConnectivity = true
      configuration.httpMaximumConnectionsPerHost = 6
      configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
      configuration.urlCache = .shared
      
      if enableLogging {
        Sniffer.enable(in: configuration)
      }
      return URLSession(configuration: configuration)
    }
  }
}
