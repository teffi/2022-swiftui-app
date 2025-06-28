//
//  SentimentDisplay.swift
//  Dash
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI

// TODO: Base on size, scale image frame and padding
/// Horizontally stacked SentimentLabel
struct SentimentDisplay: View {
  let size: SentimentLabel.Size
  let love: String
  let hate: String
  
  var body: some View {
    HStack(spacing: size.spacingInBetween) {
      SentimentLabel(title: love, sentiment: .love, size: size)
      SentimentLabel(title: hate, sentiment: .hate, size: size)
    }
  }
}

struct SentimentDisplay_Previews: PreviewProvider {
  static var previews: some View {
    SentimentDisplay(size: .small, love: "120", hate: "99")
  }
}

