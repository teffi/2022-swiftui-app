//
//  NotificationsInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 3/26/22.
//

import Foundation
import SwiftUI

//  MARK: Store
class NotificationsFeedStore: ObservableObject {
  @Published var notifications: [NotificationFeed.Item] = []
  @Published var pagination = Pagination()
  @Published var shouldLoadMore = false
  private let loadMoreOffset = 1
  
  var hasNextPage: Bool {
    return nextPage != nil
  }
  
  var nextPage: Int? {
    guard pagination.current < pagination.total else { return nil }
    return pagination.current + 1
  }
  
  func isLastNotification(_ notification: Review) -> Bool {
    guard let last = notifications.last else { return false }
    return notification.id == last.id
  }
  
  func isFirstNotification(_ notification: Review) -> Bool {
    guard let first = notifications.first else { return false }
    return notification.id == first.id
  }
  
  func update(_ newNotifications: [NotificationFeed.Item]) {
    notifications = newNotifications
  }
  
  func add(_ newNotifications: [NotificationFeed.Item]) {
    notifications.append(contentsOf: newNotifications)
  }
}

//  MARK: - Store load more
extension NotificationsFeedStore {
  func loadMoreIfNeeded(current notification: NotificationFeed.Item) {
    guard hasNextPage else { return }
    let thresholdIndex = notifications.index(notifications.endIndex, offsetBy: -loadMoreOffset)
    if notifications.firstIndex(where: { $0.id == notification.id }) == thresholdIndex {
      shouldLoadMore = true
    }
  }
}

//  MARK: Interactor
protocol NotificationsInteractable {
  func feed(page: Int, response: LoadableSubject<NotificationFeed>, store: NotificationsFeedStore)
  func notificationsState(response: LoadableSubject<NotificationFeed.State>)
}

struct NotificationsInteractor: NotificationsInteractable {
  let api: NotificationsAPI
  
  func feed(page: Int, response: LoadableSubject<NotificationFeed>, store: NotificationsFeedStore) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.feed(page: page)
      .sinkToLoadable { result in
        response.wrappedValue = result
        
        if let resultValue = result.value {
          let resultPage = resultValue.pagination?.current ?? 1
          //  We assume that if page is 1, we're starting all over
          if resultPage == 1 {
            store.update(resultValue.notifications)
          } else {
            store.add(resultValue.notifications)
          }
          
          if let pagination = resultValue.pagination {
            store.pagination = pagination
            print("store page is updated to \(store.pagination)")
          }
        }
      }
      .store(in: cancelBag)
  }
  
  func notificationsState(response: LoadableSubject<NotificationFeed.State>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.state()
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
}

struct StubNotificationsInteractor: NotificationsInteractable {
  func notificationsState(response: LoadableSubject<NotificationFeed.State>) {
    print("WARNING: Using stub StubNotificationsInteractor")
  }

  func feed(page: Int, response: LoadableSubject<NotificationFeed>, store: NotificationsFeedStore) {
    print("WARNING: Using stub StubNotificationsInteractor")
  }
}
