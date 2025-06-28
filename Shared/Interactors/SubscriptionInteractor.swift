//
//  SubscriptionInteractor.swift
//  Dash
//
//  Created by Steffi Tan on 2/27/22.
//

import Foundation

protocol SubscriptionInteractable {
  func subscribeToProduct(id: String, status: Bool, response: LoadableSubject<Response>)
}

struct SubscriptionInteractor: SubscriptionInteractable {
  let api: NotificationsAPI
  
  func subscribeToProduct(id: String, status: Bool, response: LoadableSubject<Response>) {
    let cancelBag = CancelBag()
    response.wrappedValue.setIsLoading(cancelBag: cancelBag)
    api.subscribe(body: ["object_id": id,
                         "object_type": "Product",
                         "subscribe": status])
      .sinkToLoadable { result in
        response.wrappedValue = result
      }
      .store(in: cancelBag)
  }
}

struct StubSubscriptionInteractor: SubscriptionInteractable {
  func subscribeToProduct(id: String, status: Bool, response: LoadableSubject<Response>) {
    print("WARNING: Using stub StubSubscriptionInteractor")
  }
}
