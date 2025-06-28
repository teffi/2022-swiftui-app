//
//  LikeButton.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct LikeButton: View {
  @State var mutatingCount = 0
  @Binding var isSelected: Bool
  let count: Int
  let action: () -> Void
  var bgColor: AssetsColor
  
  private let padding = EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
  
  private var hasCount: Bool {
    return mutatingCount == 0
  }
  
  private var buttonLabelTitle: String {
    return mutatingCount == 0 ? "" : String(mutatingCount)
  }
  
  init(count: Int, isSelected: Binding<Bool>, bgColor: AssetsColor = .gray_1, action: @escaping () -> Void) {
    self.count = count
    _isSelected = isSelected
    mutatingCount = count
    self.action = action
    self.bgColor = bgColor
  }
  
  var body: some View {
    Button {
      isSelected.toggle()
      if isSelected {
        mutatingCount += 1
      } else {
        mutatingCount -= 1
      }      
      action()
    } label: {
      Label(buttonLabelTitle, image: isSelected ? AssetImage.ic_thumb_up_fill.name : AssetImage.ic_thumb_up_outline.name)
        .labelStyle(IconOnTheRightLabelStyle())
        .padding(padding)
    }
    .bgAssetColor(bgColor)
    .cornerRadius(6)
    .buttonStyle(.plain)
  }
}

//  MARK: - Preview
struct LikeButton_Previews: PreviewProvider {
  static var previews: some View {
    LikeButton(count: 1, isSelected: .constant(false)) {
      // pressed
    }
  }
}

//  MARK: - IconOnTheRightLabelStyle
/// Place icon to the right and vertically center title and  icon regardless of icon size
struct IconOnTheRightLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.title
        .font(.caption)
      configuration.icon
        .scaleEffect(0.8, anchor: .center)
        .frame(width: 16, height: 16)
    }
  }
}
