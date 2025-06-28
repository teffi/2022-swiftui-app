//
//  ProductInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/15/22.
//

import Foundation
import SwiftUI
import Combine

/// Store all product properties
struct ProductStateStore {
  var isSubscribed = false
  var reviewCount = 0
  var footer: ProductFooter.ViewType = .none
  var hasReviews: Bool {
    return reviewCount > 0
  }
}

protocol ProductInteractable {
  func load(id: String, info: LoadableSubject<Product>, store: Binding<ProductStateStore>)
  func getFooterType(product: Product) -> ProductFooter.ViewType
  func create(displayName: String, imageUrl: String, externalUrl: String, result: LoadableSubject<Product>)
}

struct ProductInteractor: ProductInteractable {
  let api: ProductAPI
  
  func load(id: String, info: LoadableSubject<Product>, store: Binding<ProductStateStore>) {
    let cancelBag = CancelBag()
    info.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.getProduct(id: id)
      .sinkToLoadable { result in
        info.wrappedValue = result
        store.wrappedValue = prepareStateStore(product: result.value)
      }
      .store(in: cancelBag)
  }
  
  func create(displayName: String, imageUrl: String, externalUrl: String, result: LoadableSubject<Product>) {
    let cancelBag = CancelBag()
    result.wrappedValue.setIsLoading(cancelBag: cancelBag)
    
    api.createProduct(body: ["display_name": displayName,
                             "image_url": imageUrl,
                             "external_url": externalUrl])
      .sinkToLoadable { response in
        result.wrappedValue = response
      }
      .store(in: cancelBag)
  }
  
  private func prepareStateStore(product: Product?) -> ProductStateStore {
    guard let product = product else { return ProductStateStore() }
    
    return ProductStateStore(isSubscribed: product.hasSubscribed,
                             reviewCount: product.reviewCount,
                             footer: getFooterType(product: product))
  }
  
  
  /// Return ui footer type based on reviews count and user's state with the product
  /// - Parameter product: `Product`
  /// - Returns: `ProductFooter.ViewType`
  func getFooterType(product: Product) -> ProductFooter.ViewType {
    let hasReviews = product.reviewCount > 0
    if hasReviews {
      return product.hasReviewed ? .none : .write
    } else {
      if product.hasSubscribed {
        if let subscribers = product.subscribers {
          return .subscribers(text: subscribers.displayText, users: subscribers.users ?? [])
        }
        return .none
      } else {
        return .subscribe
      }
    }
  }
}

struct StubProductInteractor: ProductInteractable {
  func load(id: String, info: LoadableSubject<Product>, store: Binding<ProductStateStore>) {
    print("WARNING: Using stub StubProductInteractor")
  }
  
  func create(displayName: String, imageUrl: String, externalUrl: String, result: LoadableSubject<Product>) {}
  
  func getFooterType(product: Product) -> ProductFooter.ViewType {
    return .none
  }
}




