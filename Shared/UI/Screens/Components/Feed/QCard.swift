//
//  QCard.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

struct QCard: View {
  let title: String
  var body: some View {
    Card(padding: (edges: .all, value: 16)) {
      VStack(alignment: .leading, spacing: 6) {
        Image.asset(.ic_bubble_smile)
          .icon()
          .frame(width: 24, height: 24)
          .padding(.bottom, 20)
        Text(title)
          .fontHeavy(size: 16)
          .fgAssetColor(.purple)
          .lineLimit(4)
      }
    }
    .frame(width: 141)
  }
}

struct QCard_Previews: PreviewProvider {
  static var previews: some View {
    QCard(title: "What’s your best mom and baby product?")
  }
}

