//
//  KeyboardResponder.swift
//  Dash
//
//  Created by Steffi Tan on 2/11/22.
//

import SwiftUI

final class KeyboardResponder: ObservableObject {
  
  private var notificationCenter: NotificationCenter
  @Published private(set) var currentHeight: CGFloat = 0
  var isShowing: Bool {
    return currentHeight > 0
  }
  
  init(center: NotificationCenter = .default) {
    notificationCenter = center
    notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  static func dismiss() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
  
  deinit {
    notificationCenter.removeObserver(self)
  }
  
  @objc func keyBoardWillShow(notification: Notification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      currentHeight = keyboardSize.height
    }
  }
  
  @objc func keyBoardWillHide(notification: Notification) {
    currentHeight = 0
  }
}
