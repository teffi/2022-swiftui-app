//
//  NotificationsScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/26/22.
//

import SwiftUI

struct NotificationsScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @StateObject var store: NotificationsFeedStore = NotificationsFeedStore()
  @State var feed: Loadable<NotificationFeed> = .idle
  
  private var isLoading: Bool {
    switch feed {
    case .isLoading:
      return true
    default:
      return false
    }
  }
  
  var body: some View {
    buildFeed
      .padding(.vertical, 20)
      .bgAssetColor(.white)
      .onChange(of: store.shouldLoadMore, perform: { shouldLoadMore in
        print("should load: \(shouldLoadMore), request next page \(store.nextPage)")
        if shouldLoadMore && !isLoading,
           let nextPage = store.nextPage {
          load(page: nextPage)
          print("request next page")
        }
      })
      .navigationTitle("Notifications")
      .navigationBarTitleDisplayMode(.inline)
  }
  
}
//  MARK: - Views
extension NotificationsScreen {
  @ViewBuilder private var buildFeed: some View {
    switch feed {
    case .idle:
      Color.clear
        .onAppear {
          load(page: 1)
        }
    case .loaded(_):
      if store.notifications.isEmpty {
        Text("No notifications")
      } else {
        notificationsList
          .onAppear {
            let _ = print("notification loaded data")
            store.shouldLoadMore = false
          }
      }
    case .failed(_):
      Text("notification: failed data")
    case .isLoading:
      if store.shouldLoadMore {
        notificationsList
      } else {
        skeletonFeed
      }
    }
  }
  
  private var notificationsList: some View {
    List {
      ForEach(store.notifications) { notification in
        NotificationFeedItemView(notification: notification)
          .padding(.vertical, 12)
      }
      if store.hasNextPage {
        let _ = print("notifications : show loading state for next page")
        loadMoreIndicator
      }
    }
    .listStyle(.plain)
  }
  
  private var loadMoreIndicator: some View {
    HStack {
      Spacer()
      ProgressView()
      Spacer()
    }
  }
  
  private var skeletonFeed: some View {
    VStack(spacing: 40) {
      skeleton
      skeleton
      skeleton
      Spacer()
    }
    .padding(.horizontal, 20)
  }
  
  private var skeleton: some View {
    HStack(alignment: .top) {
      Circle().frame(width: 40, height: 40)
      VStack {
        Rectangle().frame(height: 10)
        Rectangle().frame(height: 10)
        Rectangle().frame(height: 10)
      }
    }
    .foregroundColor(Color(.secondarySystemBackground))
    
  }
}
//  MARK: - API
extension NotificationsScreen {
  func load(page: Int) {
    dependencies.interactors
      .notificationsInteractor.feed(page: page, response: $feed, store: store)
  }
}


//  MARK: - Preview
struct NotificationsScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      NotificationsScreen()
    }
  }
}

