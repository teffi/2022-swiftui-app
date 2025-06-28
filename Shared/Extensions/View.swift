//
//  View.swift
//  Dash
//
//  Created by Steffi Tan on 2/10/22.
//

import SwiftUI

extension View {
  /// Applies the given transform if the given condition evaluates to `true`.
  /// - Warning:
  ///   - Conditional modifiers  breaks the View's identity once the condition flips. As much as possible use ternary (?:) operator
  ///   - Example: if this is used in a view with textfield, the moment the condition changes, textfield loses its focus. It exhibits the view identity issue.
  ///   - https://stackoverflow.com/a/69328837/1045672
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
  /// Ref:  https://www.avanderlee.com/swiftui/conditional-view-modifier/
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
// MARK: - Custom modifier wrappers
  
  /// Toolbar with an  ellipsis item
  /// - Parameters:
  ///   - placement: defaults to `.navigationBarTrailing`
  ///   - perform: on tap action
  /// - Returns: `View` with added toolbar
  func toolbarEllipsis(placement: ToolbarItemPlacement = .navigationBarTrailing, willShow: Bool, action perform: @escaping () -> Void) -> some View {
    return self.modifier(EllipsisToolbar(placement: placement, willShow: willShow, action: perform))
  }

  func floatingEllipsis(tap: Binding<Bool> = .constant(false), alignment: Alignment = .topTrailing, action perform: (() -> Void)? = nil) -> some View {
    
    return self.modifier(FloatingEllipsis(tap: tap, alignment: alignment, action: {
      perform?()
    }))
  }
  
  func reviewActionSheet(isPresented: Binding<Bool>, actions: [ReviewActions.Action], perform: @escaping (ReviewActions.Action) -> Void) -> some View {
    return self.modifier(ReviewActions(presented: isPresented,
                                       actions: actions,
                                       performSelect: perform))
  }
  
  /// Backwards compatible closure based overlay.
  /// - Returns:
  @available(iOS, deprecated: 15.0, message: "Use the built-in APIs instead")
  func overlay<T: View>(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> T
  ) -> some View {
    overlay(Group(content: content), alignment: alignment)
  }
  
  @available(iOS, deprecated: 15.0, message: "Use the built-in APIs instead")
  /// Backwards compatible closure based background.
  func background<T: View>(
    alignment: Alignment = .center,
    @ViewBuilder content: () -> T
  ) -> some View {
    background(Group(content: content), alignment: alignment)
  }
  
  //  MARK: - Reusable styling
  func noPadding() -> some View {
    self.padding(0)
  }
  
  func circularBorder() -> some View {
    self.overlay(
      Circle().stroke(.white, lineWidth: 2)
    )
  }
  
  func clipInFullCircle() -> some View {
    self
      .clipShape(Circle())
      .clipped()
  }
  
  func fillAndClipToParent() -> some View {
    self
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fill)
      .clipped()
  }
  
  func addBorder(width: CGFloat = 1, color: AssetsColor, cornerRadius: CGFloat) -> some View {
    let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
    return self.clipShape(roundedRect).overlay(roundedRect.stroke(lineWidth: width).fgAssetColor(color))
  }
  
  // MARK: - OS check
  /// Sample OS check conditional view modifier. TEMPLATE ONLY
  /// - Warning:As of this writing, its not used anywhere and was just added for future reference and configuration.
  static var iOS13: Bool {
    guard #available(iOS 14, *) else {
      // It's iOS 13 so return true.
      return true
    }
    // It's iOS 14 so return false.
    return false
  }
}
