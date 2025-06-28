//
//  ShareInviteView.swift
//  Dash
//
//  Created by Steffi Tan on 3/30/22.
//

import SwiftUI

struct ShareInviteView: View {
  let code: String
  let shareCopy: String
  @State private var copyClipboardText = "Tap to copy"
  @State private var isPresentedShareSheet = false
  var body: some View {
    VStack(spacing: 40) {
      Text("Spread the word and share this app with your community")
        .fontHeavy(size: 20)
        .fgAssetColor(.black)
        .multilineTextAlignment(.center)
      
      VStack(spacing: 10) {
        Text("SHARE YOUR CODE")
          .tracking(0.69)
          .fontBold(size: 11.5)
          .fgAssetColor(.black)
        
        Text(code)
          .tracking(10)
          .fontRegular(size: 20)
          .fgAssetColor(.black)
          .padding(.vertical, 12)
          .padding(.horizontal, 27)
          .bgAssetColor(.gray_1)
          .cornerRadius(8)
          .overlay(alignment: .bottom) {
            Text(copyClipboardText)
              .fontRegular(size: 11.5)
              .fgAssetColor(.black, opacity: 0.4)
              .offset(y: 20)
          }
          .onTapGesture {
            copyToClipboard()
          }
      }
      
      Button {
        isPresentedShareSheet = true
      } label: {
        Label("Share", systemImage: "square.and.arrow.up")
          .imageScale(.large)
          .fontBold(size: 16)
          .padding(.vertical, 14)
          .padding(.horizontal, 60)
          .overlay(
            RoundedRectangle(cornerSize: .init(width: 8, height: 8))
              .stroke(Color.assetColor(.purple), lineWidth: 2)
          )
      }
      .padding(.vertical, 20)
      .appButtonStyle(.primaryText)
      .activitySheet(present: $isPresentedShareSheet, items: [shareCopy], excludedActivityTypes: nil)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 50)
    .bgAssetColor(.white)
    .cornerRadius(12)
    
  }
}
//  MARK: - Functions
extension ShareInviteView {
  private func copyToClipboard() {
    UIPasteboard.general.string = code
    copyClipboardText = "Copied!"
  }
}

struct ShareInviteView_Previews: PreviewProvider {
  static var previews: some View {
    ShareInviteView(code: "6EAS2", shareCopy: "Sample share copy")
      .padding(.horizontal, 30)
  }
}
