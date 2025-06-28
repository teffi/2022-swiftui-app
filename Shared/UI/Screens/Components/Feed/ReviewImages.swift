//
//  ReviewImages.swift
//  Dash
//
//  Created by Steffi Tan on 2/12/22.
//

import SwiftUI

struct ReviewImages: View {
  var width: CGFloat = 0
  var body: some View {

    
    GeometryReader { proxy in
      HStack(spacing: 6){
        ForEach(1..<5) { _ in
          Image("test_product_thumbnail")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .clipped()
        }
      }
      .frame(width: proxy.size.width)
      .fixedSize(horizontal: true, vertical: true)
    }
    
//    GeometryReader { proxy in
//      let imageSize = ((proxy.size.width - (6 * 3)) / 4)
//      HStack(spacing: 6){
//        ForEach(1..<5) { _ in
//          Image("test_product_thumbnail")
//            .renderingMode(.original)
//            .resizable()
//            .aspectRatio(1, contentMode: .fill)
//            .clipped()
////          .frame(width: imageSize, height: imageSize)
//        }
//      }
//      .frame(width: proxy.size.width, height: imageSize)
//      .fixedSize()
//    }
  }
}

struct ReviewImages_Previews: PreviewProvider {
  static var previews: some View {
    ReviewImages()
  }
}

