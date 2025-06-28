//
//  CustomViewModifiers.swift
//  Dash
//
//  Created by Steffi Tan on 2/11/22.
//

import SwiftUI

/// Toolbar with an  ellipsis item
struct EllipsisToolbar: ViewModifier {
  var placement: ToolbarItemPlacement
  var willShow: Bool
  var action: () -> Void
  
  func body(content: Content) -> some View {
    if willShow {
      content.toolbar {
        ToolbarItem(placement: placement) {
          Button(action: action) {
            Image(systemName: "ellipsis")
              .foregroundColor(.black)
          }
        }
      }
    } else {
      content
    }    
  }
}

/// Add ellipsis button wrapped in z stack.
/// By default ellipsis is positioned `topTrailing`
struct FloatingEllipsis: ViewModifier {
  @Binding var tap: Bool
  var alignment: Alignment = .topTrailing
  let action: () -> Void
  
  func body(content: Content) -> some View {
    ZStack(alignment: alignment) {
      content
      Button {
        tap = true
        action()
      } label: {
        Image(systemName: "ellipsis")
          .icon()
          .foregroundColor(.black)
          .opacity(0.4)
      }
      .frame(width: 24, height: 24, alignment: .center)
      .padding(4)
    }
  }
}


/// Fixed size square frame with support for corner radius
struct SquareFrame: ViewModifier {
  let size: CGFloat
  var cornerRadius: CGFloat = 0
  func body(content: Content) -> some View {
    content
      .frame(width: size, height: size)
      .fixedSize()
      .cornerRadius(cornerRadius)
  }
}

/// Fixed size square frame with circle clip
struct CircleClip: ViewModifier {
  let size: CGFloat
  func body(content: Content) -> some View {
    content
      .frame(width: size, height: size)
      .fixedSize()
      .clipInFullCircle()
  }
}


/// Build actionsheet for Review.
/// - Configure what actions to include
/// - To present, pass a binding boolean
struct ReviewActions: ViewModifier {
  enum Action {
    case share, report, edit, delete
  }
  @Binding var presented: Bool
  let actions: [Action]
  var performSelect: (Action) -> Void
  
  func body(content: Content) -> some View {
    content.actionSheet(isPresented: $presented) {
      var buttons: [Alert.Button] = []
      
      actions.forEach { action in
        switch action {
        case .share:
          buttons.append(.default(Text("Share"), action: {
            print("review card: share on action sheet")
            performSelect(.share)
          }))
        case .report:
          buttons.append(.default(Text("Report"), action: {
            print("review card: pressed report on action sheet")
            performSelect(.report)
          }))
        case .edit:
          buttons.append(.default(Text("Edit"), action: {
            print("pressed notify on action sheet")
            performSelect(.edit)
          }))
        case .delete:
          buttons.append(.default(Text("Delete"), action: {
            print("pressed notify on action sheet")
            performSelect(.delete)
          }))
        }
      }
      buttons.append(.cancel())
      return ActionSheet(title: Text("Select"), buttons: buttons)
    }
  }
}
