//
//  TagButton.swift
//  Dash
//
//  Created by Steffi Tan on 2/22/22.
//

import SwiftUI

struct TagButton: View {
  var title: String = ""
  @State var isSelected = false
  var onToggle: ((Bool) -> Void)?

  var body: some View {
    Button(action:{
      isSelected.toggle()
      onToggle?(isSelected)
    }) {
      Text(title)
        .fontBold(size: 14)
        .fgAssetColor(isSelected ? .white : .black)
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .overlay(content: {
          if !isSelected {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
              .stroke(.black, lineWidth: 1.6)
          }
        })
    }
    .background(isSelected ? Color.assetColor(.purple) : .white)
    .clipShape(RoundedRectangle(cornerRadius: 6))
    .buttonStyle(.plain)
  }
}

struct TagButton_Previews: PreviewProvider {
  static var previews: some View {
    TagButton(title: "sample", isSelected: true)
  }
}
