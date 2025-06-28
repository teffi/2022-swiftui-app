//
//  CancelBag.swift
//  Dash
//
//  Created by Steffi Tan on 2/17/22.
//

import Combine

final class CancelBag {
  fileprivate(set) var subscriptions = Set<AnyCancellable>()
  
  func cancel() {
    subscriptions.removeAll()
  }
}

extension AnyCancellable {
  func store(in cancelBag: CancelBag) {
    cancelBag.subscriptions.insert(self)
  }
}
