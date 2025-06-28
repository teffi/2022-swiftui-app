//
//  SentimentLabel.swift
//  Dash
//
//  Created by Steffi Tan on 2/9/22.
//

import SwiftUI

struct SentimentLabel: View {
  enum Size {
    case large, medium, small
    var spacingInBetween: CGFloat {
      switch self {
      case .large:
        return 30
      case .medium:
        return 18
      case .small:
        return 13
      }
    }
    var icon: CGFloat {
      switch self {
      case .large:
        return 30
      case .medium:
        return 22
      case .small:
        return 18
      }
    }
  }
  let title: String
  let sentiment: Sentiment
  let size: Size

  
  var body: some View {
    Label {
      Text(title)
        .fontSemibold(size: 11.5)
    } icon: {
      Image(sentiment.iconName)
        .icon()
        .frame(width: size.icon)
    }
  }
}

struct SentimentLabel_Previews: PreviewProvider {
  static var previews: some View {
    SentimentLabel(title: "99", sentiment: .love, size: .small)
  }
}
