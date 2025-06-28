//
//  ProductStore.swift
//  Dash
//
//  Created by Steffi Tan on 2/10/22.
//

import SwiftUI

class ProductStore: ObservableObject {
  
  @Published var footerViewType: ProductFooter.ViewType = .write
  @Published var isSubscribed = false

  let productId: String
//  let productName = "COSRX Good Morning Cleanser" // Sample only
//
//
  init(id: String) {
    productId = id
  }
  
  private func getProductInfo() {
    // TODO: Send to API
  }
  
  func getReviews() {
    // TODO: Send to API, support pagination
  }
  
  func subscribe() {
//    // TODO: Send to API
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
//      self?.footerViewType = .subscribers
//    }
  }
  
  func reload() {
    getProductInfo()
    getReviews()
    //  Test only. Assuming product is reloaded 
    footerViewType = .none
    //state = .filled
    print("reload data")
  }
}
