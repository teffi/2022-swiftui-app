//
//  Card.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI
/// View that wraps its content in a VStack and apply card styles
/// - Important:
///   - Content is wrapped in a navigation link if a Destination is provided.
///   - See Card extension file for initialiser without destination
/// Ref: https://stackoverflow.com/a/63636270/1045672
struct Card<Content: View, Destination: View>: View {
  var padding: (edges: Edge.Set, value: CGFloat) = (.all, value: 20)
  var content: () -> Content
  var destination: () -> Destination
  
  /// Returns `false` if `Card` is initialised without a destination. See `Card` extension
  private var hasDestination: Bool

  init(padding: (edges: Edge.Set, value: CGFloat) = (.all, value: 20),
  @ViewBuilder destination: @escaping () -> Destination,
  @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.padding = padding
    self.destination = destination
    hasDestination = true
  }

  init(@ViewBuilder destination: @escaping () -> Destination, @ViewBuilder _ content: @escaping () -> Content ) {
    self.content = content
    self.destination = destination
    hasDestination = true
  }
  
  var body: some View {
    if hasDestination {
      NavigationLink(destination: destination) {
        buildContent()
      }
      .appButtonStyle(.flatLink)
    } else {
      buildContent()
    }
  }
  
  @ViewBuilder func buildContent() -> some View {
    content()
      .padding(padding.edges, padding.value)
      .background(Color.white)
      .cornerRadius(12)
  }
}

//  MARK: - Extension
//  Creates initialiser with dummy destination.
extension Card where Destination == EmptyView {
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.init(destination: { EmptyView() }, content: content)
    hasDestination = false
  }
  
  init(padding: (edges: Edge.Set, value: CGFloat) = (.all, value: 20),
  @ViewBuilder _ content: @escaping () -> Content) {
    self.init(padding: padding, destination: { EmptyView() }, content: content)
    hasDestination = false
  }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
      Card {
        Text("hello world")
          .background(Color.yellow)
        Text("hello world2")
          .background(Color.red)
      }
    }
}
