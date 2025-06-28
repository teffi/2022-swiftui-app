//
//  PullToRefreshScrollView.swift
//  Dash
//
//  Created by Steffi Tan on 3/25/22.
//

import SwiftUI

struct PullToRefreshScrollView<Content: View>: View {
  let coordinateSpaceName: CoordinateSpace = .named("scrollview")
  @Binding var isRefreshing: Bool
  var content : Content
  
  init(isRefreshing: Binding<Bool>, @ViewBuilder content: () -> Content) {
    self.content = content()
    _isRefreshing = isRefreshing
  }
  
  var body: some View {
    ScrollView {
      RefreshControl(coordinateSpace: coordinateSpaceName, isRefreshing: $isRefreshing)
      content
    }
    .coordinateSpace(name: coordinateSpaceName)
  }
}

struct PullToRefreshScrollView_Previews: PreviewProvider {
  static var previews: some View {
    PullToRefreshScrollView(isRefreshing: .constant(false)) {
      LazyVStack(alignment: .leading) {
        ForEach(0..<50) { i in
          Text("\(i)")
        }
      }
    }
  }
}

