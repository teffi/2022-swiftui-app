//
//  InteractorsContainer.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
// MARK: - Interactors
extension DIContainer {
  /// List all `Interactors` used on the app
  struct Interactors {
    let productInteractor: ProductInteractable
    let reviewsInteractor: ReviewsInteractable
    let searchInteractor: SearchInteractable
    let feedInteractor: FeedInteractable
    let profileInteractor: ProfileInteractable
    let authInteractor: AuthInteractable
    let subscriptionInteractor: SubscriptionInteractable
    let notificationsInteractor: NotificationsInteractable
    let accountInteractor: AccountInteractable
    let reportInteractor: ReportInteractable
    
    init(product: ProductInteractable,
         reviews: ReviewsInteractable,
         search: SearchInteractable,
         feed: FeedInteractable,
         profile: ProfileInteractable,
         auth: AuthInteractable,
         subscription: SubscriptionInteractable,
         notifications: NotificationsInteractable,
         account: AccountInteractable,
         report: ReportInteractable) {
      self.productInteractor = product
      self.reviewsInteractor = reviews
      self.searchInteractor = search
      self.feedInteractor = feed
      self.profileInteractor = profile
      self.authInteractor = auth
      self.subscriptionInteractor = subscription
      self.notificationsInteractor = notifications
      self.accountInteractor = account
      self.reportInteractor = report
    }
    
    static var stub: Self {
      .init(product: StubProductInteractor(),
            reviews: StubReviewsInteractor(),
            search: StubSearchInteractor(),
            feed: StubFeedInteractor(),
            profile: StubProfileInteractor(),
            auth: StubAuthInteractor(),
            subscription: StubSubscriptionInteractor(),
            notifications: StubNotificationsInteractor(),
            account: StubAccountInteractor(),
            report: StubReportInteractor())
    }
  }
}

