//
//  RefreshControl.swift
//  Dash
//
//  Created by Steffi Tan on 3/25/22.
//

import SwiftUI

//  Inspired from https://gist.github.com/prafullakumar/4bb1540ba2c11353bd18d83c759b9b66
struct RefreshControl: View {
  var coordinateSpace: CoordinateSpace
  @Binding var isRefreshing: Bool
  var threshold: CGFloat = 80
  
  var body: some View {
    GeometryReader { geo in
      if (geo.frame(in: coordinateSpace).midY > threshold) {
        Spacer().onAppear { isRefreshing = true }
      } else {
        Spacer().onAppear { isRefreshing = false }
      }
      
      ZStack {
        //  Show loading indicator when refreshing
        if isRefreshing {
          ProgressView()
        } else {
          ///  Area displayed before switching to progressview when threshold is reached
          //Text("pulling")
        }
      }
      .frame(width: geo.size.width)
    }
    ///  Negative padding for moving refresh view  beyond bounds of the container
    ///  Positive padding for creating space for refresh view to be visible
    ///  Normally you'll use the threshold value
    .padding(.top, isRefreshing ? 20 : -threshold)
    .padding(.bottom, isRefreshing ? 20 : 0)
  }
}

struct PullToRefreshDemo: View {
  var body: some View {
    ScrollView {

      RefreshControl(coordinateSpace: .named("RefreshControl"), isRefreshing: .constant(true))
      Text("Some view...")
    }.coordinateSpace(name: "RefreshControl")
  }
}

struct PullToRefreshDemo_Previews: PreviewProvider {
  static var previews: some View {
    PullToRefreshDemo()
  }
}
