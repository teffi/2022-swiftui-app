//
//  ContainerView.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

/// Contains boilerplate for creating basic init a custom container views.
/// Ref: https://www.swiftbysundell.com/tips/creating-custom-swiftui-container-views/
protocol ContainerView: View {
  associatedtype Content
  init(content: @escaping () -> Content)
}

extension ContainerView {
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.init(content: content)
  }
}
