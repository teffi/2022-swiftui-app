//
//  SearchProductRow.swift
//  Dash
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI

struct SearchProductRow: View {
  let name: String
  let imageUrl: String
  let loveCount: Int
  let hateCount: Int
  
  var body: some View {
    HStack(alignment: .center, spacing: 20) {
      ImageRender(urlPath: imageUrl, placeholderRadius: 8) { image in
        image.thumbnail()
      }
      .modifier(SquareFrame(size: 69, cornerRadius: 8))

      VStack(alignment: .leading, spacing: 12) {
        Text(name)
          .fontHeavy(size: 14)
          .lineLimit(3)
          .lineSpacing(2)
          .multilineTextAlignment(.leading)
          .padding(.leading, 0)
        
        if loveCount > 0 || hateCount > 0 {
          SentimentDisplay(size: .small,
                           love: String(loveCount),
                           hate: String(hateCount))
        }
      }.padding(.bottom, 9)
      Spacer()
    }.background(Color.white)
  }
}

struct SearchProductRow_Previews: PreviewProvider {
  static var previews: some View {
    Image("test_product_portrait")
      .thumbnail()
      .modifier(SquareFrame(size: 69, cornerRadius: 8))
    
    SearchProductRow(name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt",
                     imageUrl: "https://datcmftzrmvb3.cloudfront.net/spree/product_images/250431/tile/Dear-Klairs-Daily-Skin-Softening-Water_bottle.jpg?1575953576",
                     loveCount: 10,
                     hateCount: 20)
  }
}

