//
//  FeedInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation
//  MARK: - Feed store

class FeedStore: ObservableObject {
  typealias Card = Feed.Card
  
  enum Position {
    case first
    case last
  }
  
  @Published var cards: [Feed.Card] = []
  @Published var shouldLoadMorePastCards = false
  /// Set to true to disable changing `shouldLoadMorePastCards` from being set as `true` in `loadMorePastCardsIfNeeded`
  @Published var hasNoMorePastCards = false
  /// Offset position of the card that will signify that we could load more cards. See `loadMorePastCardsIfNeeded`
  private let loadMorePastCardOffset = 1
  /// List of card types that has real time timestamps
  private let realTimeCardTypes: Set<Feed.CardType> = [.review, .subscriptions]
  
  /// Cards types that are real time. Currently `.review` and `.subscription (Waiting for review)`
  private var realTimeCards: [Card] {
    cards.filter( { $0.cardType == .review || realTimeCardTypes.contains($0.cardType) } )
  }
  
  func update(_ newCards: [Card]) {
    cards = newCards
  }
  
  func append(_ newCards: [Card]) {
    cards.append(contentsOf: newCards)
  }
  
  func prepend(_ newCards: [Card]) {
    cards.insert(contentsOf: newCards, at: 0)
  }
  
  /// Return card timestamp at given posiiton
  /// - IMPORTANT:
  ///   - Card is from a filtered cards with only real time timestamps. See `realTimeCards`
  /// - Parameter position:
  /// - Returns:
  func getCardTimestamp(position: Position) -> String? {
    switch position {
    case .first:
      return realTimeCards.first?.timestamp
    case .last:
      return realTimeCards.last?.timestamp
    }
  }
  
  /// Checks if the given card index position is in our specified threshold and if there's more past cards.
  /// If `true` `shouldLoadMorePastCards` is set to `true`
  /// - Parameter card:
  func loadMorePastCardsIfNeeded(current card: Card) {
    guard !hasNoMorePastCards else { return }
    let thresholdIndex = cards.index(cards.endIndex, offsetBy: -loadMorePastCardOffset)
    if cards.firstIndex(where: { $0.id == card.id }) == thresholdIndex {
      shouldLoadMorePastCards = true
      print("should load more")
    }
  }
  
}

protocol FeedInteractable {
  func load(lastTimestamp: String?,
            mode: FeedInteractor.Order?,
            response: LoadableSubject<Feed>,
            store: FeedStore)
  func checkAppUpdate(completed: @escaping ((Bool) -> ()))
}

struct FeedInteractor: FeedInteractable {
  let api: FeedAPI
  
  enum Order: String {
    case before
    case after
  }
  
  func load(lastTimestamp: String?,
            mode: FeedInteractor.Order?,
            response: LoadableSubject<Feed>,
            store: FeedStore) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.load(timestamp: lastTimestamp, mode: mode?.rawValue)
      .sinkToLoadable { result in
        response.wrappedValue = result
        let cards = result.value?.cards ?? []
        switch mode {
        case .after:
          //  .after returns most recent cards
          store.prepend(cards)
        case .before:
          //  .before returns past cards
          /// If there's no more cards from the response it means we reached the end.
          if cards.isEmpty {
            store.hasNoMorePastCards = true
          } else {
            store.append(cards)
          }
        case .none:
          store.update(cards)
        }
      }
      .store(in: cancelBag)
  }
  
  
  //  We need strong reference
  private let cancelBag = CancelBag()
  func checkAppUpdate(completed: @escaping ((Bool) -> ())) {
    api.checkAppUpdate()
      .sinkToResult { result in
        switch result {
        case let .success(data):
          completed(data.shouldForceUpdate)
        case .failure:
          completed(false)
        }
      }
      .store(in: cancelBag)
  }
}

struct StubFeedInteractor: FeedInteractable {
  func checkAppUpdate(completed: @escaping ((Bool) -> ())) {
    print("WARNING: Using stub StubFeedInteractor")
  }
  
  func load(lastTimestamp: String?, mode: FeedInteractor.Order?, response: LoadableSubject<Feed>, store: FeedStore) {
    print("WARNING: Using stub StubFeedInteractor")
  }
}
