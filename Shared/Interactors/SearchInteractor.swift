//
//  SearchInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/16/22.
//

import Foundation
protocol SearchInteractable {
  func getProducts(query: String, page: Int, items: LoadableSubject<Search.Products>)
  func getSuggestions(questionId: String?, items: LoadableSubject<Search.Products>)
  func lookUp(url: String, result: LoadableSubject<Search.Lookup>)
}

struct SearchInteractor: SearchInteractable {
  let api: SearchAPI
  
  func getProducts(query: String, page: Int, items: LoadableSubject<Search.Products>) {
    let cancelBag = CancelBag()
    items.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.searchProduct(query: query, page: page)
      .sinkToLoadable { result in
        items.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func getSuggestions(questionId: String?, items: LoadableSubject<Search.Products>) {
    let cancelBag = CancelBag()
    items.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.searchSuggestions(questionId: questionId)
      .sinkToLoadable { result in
        items.wrappedValue = result
      }
      .store(in: cancelBag)
  }
  
  func lookUp(url: String, result: LoadableSubject<Search.Lookup>) {
    let cancelBag = CancelBag()
    result.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.lookUp(url: url)
      .sinkToLoadable { data in
        result.wrappedValue = data
      }
      .store(in: cancelBag)
  }
}

struct StubSearchInteractor: SearchInteractable {
  func getSuggestions(questionId: String?, items: LoadableSubject<Search.Products>) {
    print("WARNING: Using stub StubSearchInteractor")
  }
  
  func getProducts(query: String, page: Int, items: LoadableSubject<Search.Products>) {
    print("WARNING: Using stub StubSearchInteractor")
  }
  
  func lookUp(url: String, result: LoadableSubject<Search.Lookup>) {}
}
