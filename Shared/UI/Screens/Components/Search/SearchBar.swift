//
//  SearchBar.swift
//  Dash
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI

struct SearchBar: View {
  @Binding var text: String
  @State private var isEditing = false
  /// Set to `false` to disable textfield events.
  /// - Important: This is a non-binding property. Used only for configuration.
  var isEditable: Bool
  var textFieldColor = Color.assetColor(.gray_1)
  
  var body: some View {
    HStack {
      TextField("Search", text: $text)
        .fontRegular(size: 16)
        .fgAssetColor(.black)
        .padding(7)
        .padding(.horizontal, 36)
        .background(textFieldColor)
        .cornerRadius(8)
      //  Add magnifying glass icon and close button which appears when editing
        .overlay(
          addOverlays()
        )
      //  If not editable, change field to readonly
        .disabled(!isEditable)
      
      //  Register tap gesture when field is editable. This uses a conditional view modifier wrapper. See `View` extension.
        .if(isEditable, transform: { view in
          view.onTapGesture {
            isEditing = true
            print("tap field")
          }
        })
        
      if isEditing {
        // Cancel button
        Button {
          // Action closure - on tap button
          isEditing = false
          dismissKeyboard()
        } label: {
          Text("Cancel")
            .fontRegular(size: 16)
        }
        .fgAssetColor(.black)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        //.transition(.move(edge: .trailing))
        //.animation(.linear(duration: 0.2))
      }
    }
  }
  
  private func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

private extension SearchBar {
  @ViewBuilder func addOverlays() -> some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
      
      if isEditable && isEditing {
        Button(action: {
          self.text = ""
          print("should clear textfield text - \(self.text)")
        }) {
          Image(systemName: "multiply.circle.fill")
            .foregroundColor(.gray)
            .padding(.trailing, 8)
        }
      }
    }
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    SearchBar(text: .constant(""), isEditable: true)
  }
}

