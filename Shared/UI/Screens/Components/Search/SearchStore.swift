//
//  SearchStore.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI

/// Search result data source. Runs api request to get search results from keywords
class SearchStore: ObservableObject {
  @Published var searchText: String = ""
  @Published var resultItems: [Search.Product] = []
  @Published var suggestedItems: [Search.Product] = []
  
  private(set) var currentResultKeyword: String?

  private var currentPage = 1
  /// Set to false if data is maxed out
  private var canLoadMore = true
  /// Index offset from last index of `results`. Defaults to -1.
  /// This means that `getContent()` will be executed when last index from the current total `results` appeared in view.
  let loadMoreIndexOffset: Int
  
  init(_ loadMoreIndexOffset: Int? = nil) {
    self.loadMoreIndexOffset = loadMoreIndexOffset ?? -1
  }
  
  /// Replace current with new array
  /// - Parameter products: Search.Product
  func updateResult(products: [Search.Product]) {
    clearSearchResults()
    resultItems.append(contentsOf: products)
  }
  
  /// Insert array content to current list
  /// - Parameter products:
  func insertProducts(products: [Search.Product]) {
    guard !products.isEmpty else { return }
    print("search: before insert data result total count \(resultItems.count)")
    resultItems.append(contentsOf: products)
    print("search: insert data result total count \(resultItems.count)")
  }
  
  /// Replace current with new array
  /// - Parameter products: Search.Product
  func updateSuggestions(products: [Search.Product]) {
    clearSearchSuggestions()
    suggestedItems.append(contentsOf: products)
  }
  
  func insertSuggestions(products: [Search.Product]) {
    guard !products.isEmpty else { return }
    print("search: before insert data suggestion total count \(suggestedItems.count)")
    suggestedItems.append(contentsOf: products)
    print("search: insert data suggestion total count \(suggestedItems.count)")
  }
  
  func clearSearchResults() {
    resultItems.removeAll()
    print("search: clear search result")
  }
  
  func clearSearchSuggestions() {
    suggestedItems.removeAll()
    print("search: clear search result")
  }
  
  func loadMoreContentIfNeeded(currentItem item: Search.Product?) {
    guard let item = item else {
      //getContent()
      return
    }
    
    //  get new content when current item is reached the given threshold
//    let thresholdIndex = results.index(results.endIndex, offsetBy: loadMoreIndexOffset)
//    if results.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
//      print("did reach threshold index at \(thresholdIndex). Invoking getContent(...)")
//      getContent(keyword: currentResultKeyword ?? "")
//    }
  }
  
  private func getContent(keyword: String) {
    // TODO: Send to API, on response we should store the keyword, current page.
    print("keyword to search - \(keyword)")
    
    //  If keyword is not the current keyword, cancel pagination request. Start new search.
    if let word = currentResultKeyword, word.lowercased() != keyword.lowercased() {
      print("getting content for new keyword")
    } else if canLoadMore {
      // TODO: Check if there's need to add condition for checking if there's an loading progress of the same keyword and page.
      print("getting content for same keyword. Pagination call.")
    } else {
      print("Failed to get content - canLoadMore: \(canLoadMore)")      
    }
    currentResultKeyword = keyword
  }
  
  
}
