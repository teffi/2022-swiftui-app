//
//  UINavigationViewController.swift
//  Dash
//
//  Created by Steffi Tan on 3/31/22.
//

import UIKit

extension UINavigationController {
  // Remove back button text
  open override func viewWillLayoutSubviews() {
    navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}
