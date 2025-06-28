//
//  SearchScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI

struct SearchScreen: View {
  @Environment(\.injected) private var dependencyEnv: DIContainer
  @EnvironmentObject var environment: SearchEnvData
  @StateObject private var store = SearchStore()
  @State private var searchText = ""
  
  @State var searchResult: Loadable<Search.Products>
  @State var suggestions: Loadable<Search.Products>
  
  @State var items: [Search.Product] = []
  @State var suggestedItems: [Search.Product] = []
  
  @State var addingProduct = false
  
  /// `true` when search bar is actively being interacted.
  @State var isActiveSearch = false
  
  private let cancelBag = CancelBag()
  
  init() {
    _searchResult = .init(initialValue: .idle)
    _suggestions = .init(initialValue: .idle)
    //_searchStore = StateObject.init(wrappedValue: SearchStore())
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      //  Observe change in searchText value using onChange
      SearchBar(text: $store.searchText, isEditable: true)
        .padding(.horizontal, 20)
      
      if addingProduct {
        AddProductForm()
          .frame(maxHeight: .infinity)
      } else if store.resultItems.isEmpty && !isActiveSearch {
        buildSuggestions()
      } else {
        buildSearchResult()
      }
    }
    .navigationBarHidden(true)
    
    //  Observe changes in search result loadable
    .onChange(of: searchResult.value, perform: { newValue in
      guard let items = newValue?.results else { return }
      //  TODO: If pagination support is added, edit this to include keyword and page check to determine if we're inserting or updating
      store.updateResult(products: items)
    })
    
    //  Observe changes in search suggestions loadable
    .onChange(of: suggestions.value, perform: { newValue in
      guard let items = newValue?.results else { return }
      //  TODO: If pagination support is added, edit this to include keyword and page check to determine if we're inserting or updating
      store.updateSuggestions(products: items)
    })
    
    //  Observe changes in search result
    .onChange(of: store.resultItems, perform: { newValue in
      items = newValue
    })
    
    // Observe changes in  suggestion items datasource
    .onChange(of: store.suggestedItems, perform: { newValue in
      suggestedItems = newValue
    })
    
    .onAppear {
      //  Run search text publisher with delay
      store.$searchText
        .debounce(for: 0.5, scheduler: DispatchQueue.main)
        .sink(receiveValue: { text in
          if !text.isEmpty {
            print("search: searching \(text)")
            addingProduct = false
            isActiveSearch = true
            search(query: text)
          } else {
            store.clearSearchResults()
            searchResult = .idle
            isActiveSearch = false
            addingProduct = false
          }
        })
        .store(in: cancelBag)
    }
  }
}
// MARK: - Views
extension SearchScreen {
  @ViewBuilder func buildSearchResult() -> some View {
    switch searchResult {
    case .idle:
      Color.clear
    case .loaded(let data):
      //  If there's no result, switch to adding product.
      if data.results.isEmpty {
        Color.clear.onAppear {
          addingProduct = data.results.isEmpty
        }
      }
      SearchResultView(store: store, products: $items, switchToAddProduct: $addingProduct, viewId: "search-result")
      
    case .failed(_):
      //  TODO: Check if we need to use a error state view or just use the add product.
      Color.clear.onAppear {
        addingProduct = true
      }
    case .isLoading(_, _):
      let _ = print("search: result is loading")
      if store.resultItems.isEmpty {
        Color.clear
      } else {
        SearchResultView(store: store, products: $items, switchToAddProduct: $addingProduct, viewId: "search")
      }
    }
  }
  
  @ViewBuilder private func buildSuggestions() -> some View {
    switch suggestions {
    case .idle:
      Color.clear
        .onAppear {
          loadSuggestions(questionId: environment.tab?.searchQuestion?.id ?? nil)
        }
    case .loaded(let data):
      SearchResultView(store: store, products: $suggestedItems, switchToAddProduct: $addingProduct, viewId: "suggestions")
    case .failed(_):
      VStack {
        Text("Oops!\nWe're having trouble loading top product suggestions")
          .fontBold(size: 14)
          .fgAssetColor(.black).opacity(0.4)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 20)
      }.frame(maxHeight: .infinity)
    case .isLoading(_, _):
      let _ = print("search: suggestion is loading")
      skeletonFeed
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
    .padding(.vertical, 20)
  }
  
  private var skeleton: some View {
    HStack(alignment: .top) {
      Rectangle().frame(width: 69, height: 69)
        .cornerRadius(8)
      VStack {
        Rectangle().frame(height: 10)
        Rectangle().frame(height: 10)
        Rectangle().frame(height: 10)
      }
    }
    .foregroundColor(Color(.secondarySystemBackground))
    
  }
  
}

// MARK: - API functions
extension SearchScreen {
  func search(query: String) {
    dependencyEnv.interactors.searchInteractor.getProducts(query: query, page: 1, items: $searchResult)
  }
  
  func loadSuggestions(questionId: String? = nil) {
    dependencyEnv.interactors.searchInteractor.getSuggestions(questionId: questionId, items: $suggestions)
  }
}


struct SearchScreen_Previews: PreviewProvider {
  static var previews: some View {
    SearchScreen().environmentObject(SearchEnvData())
  }
}
