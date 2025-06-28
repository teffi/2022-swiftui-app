//
//  FeedScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct FeedScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject private var tab: TabController
  @State var searchBarText: String = ""
  @State var isRefreshing = false
  @State var feed: Loadable<Feed> = .idle
  @State var notifications: Loadable<NotificationFeed.State> = .idle
  @StateObject var store: FeedStore = FeedStore()
  
  private var isLoading: Bool {
    switch feed {
    case .isLoading:
      return true
    default:
      return false
    }
  }
  var body: some View {
    PullToRefreshScrollView(isRefreshing: $isRefreshing, content: {
      HStack(spacing: 0) {
        SearchBar(text: $searchBarText, isEditable: false, textFieldColor: Color.white)
          .padding(.horizontal, 20)
          .onTapGesture {
            tab.isPresentedSearch = true
          }
        //  Notification icon
        NavigationLink {
          NotificationsScreen()
        } label: {
          notificationBell
        }

      }
      
      buildFeed()
    })
      .background(Color.assetColor(.gray_1).ignoresSafeArea())
      .onChange(of: isRefreshing, perform: { newValue in
        print("is refreshing \(newValue)")
        if isRefreshing && !isLoading {
          // Get first card timestamp and load data past that.
          load(lastTimestamp: store.getCardTimestamp(position: .first), mode: .after)
        }
      })
      .onChange(of: store.shouldLoadMorePastCards, perform: { shouldLoad in
        // Get last card timestamp and load data before that
        //  If value is true and there's no loading in progress
        if shouldLoad && !isLoading {
          load(lastTimestamp: store.getCardTimestamp(position: .last), mode: .before)
        }
      })
    //  For debugging purpose.
      .onChange(of: notifications, perform: { notification in
        switch notification {
        case .loaded(let result):
          print("feed notification has new: \(result.hasNewNotifications)")
        default:
          break;
        }
      })
      .onAppear {
        checkForNotifications()
      }
      .navigationBarHidden(true)
  }
}

// MARK: - View Builder
extension FeedScreen {
  var content: some View {
    LazyVStack(alignment: .leading) {
      ForEach(store.cards) { card in
        cardView(card: card)
          .onAppear {
            store.loadMorePastCardsIfNeeded(current: card)
          }
      }
      
      if store.shouldLoadMorePastCards {
        loadMoreIndicator
      }
    }
    
    .padding(.vertical, 20)
  }
  
  private var loadMoreIndicator: some View {
    HStack {
      Spacer()
      ProgressView()
      Spacer()
    }
  }
  
  private var notificationBell: some View {
    Image.asset(.ic_notifications)
      .icon()
      .frame(width: 20, height: 20)
      .padding(.trailing, 20)
      .padding(.vertical, 10)
      .overlay(alignment: .topLeading) {
        let hasNotification = notifications.value?.hasNewNotifications ?? false
        if hasNotification {
          Circle()
            .fill(Color.red)
            .frame(width: 7, height: 7)
            .offset(x: -6, y: 3)
        }
      }
  }
  
  @ViewBuilder private func buildFeed() -> some View {
    switch feed {
    case .idle:
      Color.clear
        .onAppear {
          load()
        }
    case .loaded:
      content
        .onAppear {
          let _ = print("feed loaded data")
          //  Reset both api data request triggers
          isRefreshing = false
          store.shouldLoadMorePastCards = false
        }
    case .failed(let response):
      VStack {
        Spacer()
        Text(parseToErrorCopy(using: response))
          .fontBold(size: 14)
          .fgAssetColor(.black).opacity(0.4)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 20)
        Spacer()
      }
      .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.5)
    case .isLoading(_, _):
      if isRefreshing || store.shouldLoadMorePastCards {
        content
      } else {
        VStack {
          Card { skeleton }
          Card { skeleton }
          Card { skeleton }
        }.padding(.vertical, 20)
      }
    }
  }
  
  @ViewBuilder private func cardView(card: Feed.Card) -> some View {
    switch card.cardType {
    case .review:
      if let model = card.data as? Review {
        ReviewCard(review: model)
          .padding(.horizontal, 20)
      }
    case .subscriptions:
      if let model = card.data as? Feed.Subscriptions {
        WaitingForReviewCard(model: model)
          .padding(.horizontal, 20)
      }
    case .users:
      if let model = card.data as? Feed.Users {
        NewUsersView(title: model.title,
                     text: model.summary.displayText,
                     users: model.summary.users ?? [])
          .padding(.vertical, 24)
          .padding(.horizontal, 20)
      }
    case .products:
      if let model = card.data as? Feed.Products {
        ProductsCard(title: model.title, products: model.products)
          .padding(.horizontal, 20)
      }
    case .questions:
      if let model = card.data as? Feed.Questions {
        QCardCarousel(questions: model.questions)
      }
      
    default:
      Color.clear
    }
  }
  
  private var skeleton: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 20) {
        Circle().frame(width: 36, height: 36)
        VStack(alignment: .leading) {
          Rectangle().frame(width: 230, height: 12)
          Rectangle().frame(width: 170, height: 12)
        }
      }
      Spacer(minLength: 20)
      Rectangle().frame(width: 100, height: 16)
      Rectangle().frame(width: 170, height: 16)
      Rectangle().frame(width: 210, height: 16)
    }
    .padding(.vertical, 20)
    .foregroundColor(Color(.secondarySystemBackground))
  }
}
// MARK: - API
extension FeedScreen {
  func load(lastTimestamp: String? = nil, mode: FeedInteractor.Order? = nil) {
    dependencies.interactors.feedInteractor
      .load(lastTimestamp: lastTimestamp,
            mode: mode,
            response: $feed,
            store: store)
  }
  
  func checkForNotifications() {
    dependencies.interactors.notificationsInteractor
      .notificationsState(response: $notifications)
  }
  
  // MARK: - Function
  private func parseToErrorCopy(using response: Error) -> String {
    var title = "Something went wrong"
    var message = response.localizedDescription
    if let err = response.asAPIError {
      title = err.alert.title
      message = err.alert.message
    }
    return "\(title)\n\(message)"
  }
}

struct FeedScreen_Previews: PreviewProvider {
  static var previews: some View {
    FeedScreen()
  }
}

//@ViewBuilder private func dummyCards() -> some View {
//      QCardCarousel()
//      NewUsersView()
//        .padding(.vertical, 24)
//        .padding(.horizontal, 20)
//      ReviewCard()
//        .padding(.horizontal, 20)
//      WaitingForReviewCard()
//        .padding(.horizontal, 20)
//      ProductsCard()
//        .padding(.horizontal, 20)
//  }

