//
//  TrendingScreen.swift
//  Dash
//
//  Created by Steffi Tan on 3/1/22.
//

import SwiftUI

struct TrendingScreen: View {
  @EnvironmentObject private var tab: TabController
  let products: [Review.Product]
  
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        ForEach(products) { product in
          buildRow(product)
            .padding(.bottom, 12)
            .onTapGesture {
              tab.goToProduct(id: product.id)
            }
      
        }
      }
      .padding(20)
      .navigationBarHidden(false)
      .navigationTitle("Trending products")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  @ViewBuilder func buildRow(_ product: Review.Product) -> some View {
    HStack(alignment: .center, spacing: 20) {
      ImageRender(urlPath: product.image.mediumUrl, placeholderRadius: 8) { image in
        image.thumbnail()
      }
      .modifier(SquareFrame(size: 69, cornerRadius: 8))
      
      VStack(alignment: .leading, spacing: 12) {
        Text(product.displayName)
          .fontHeavy(size: 14)
          .lineLimit(3)
          .lineSpacing(2)
          .multilineTextAlignment(.leading)
          .padding(.leading, 0)
        
        if product.loveCount > 0 || product.hateCount > 0 {
          SentimentDisplay(size: .small,
                           love: String(product.loveCount),
                           hate: String(product.hateCount))
        }
      }
      .padding(.bottom, 9)
      Spacer()
    }
    .background(Color.white)
  }
}

struct TrendingScreen_Previews: PreviewProvider {
  static var previews: some View {
    TrendingScreen(products: [])
  }
}

