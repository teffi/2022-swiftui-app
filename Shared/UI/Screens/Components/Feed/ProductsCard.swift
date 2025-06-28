//
//  ProductsCard.swift
//  Dash
//
//  Created by Steffi Tan on 2/13/22.
//

import SwiftUI

struct ProductsCard: View {
  @EnvironmentObject private var tab: TabController
  
  let title: String
  let products: [Review.Product]
  var previewProducts: [Review.Product] {
    let arraySlice = products.prefix(6)
    return Array(arraySlice)
  }
  
  //  TODO: Replace string with item index or item object
  //  Uncomment if enabling on select catch.
  var onSelectItem: ((String) -> Void)? = nil
  
  /// If `true` , view will navigate to product screen using its own navigation link.
  /// If `false`, view will use environment's `TabController` object to navigate to product screen.
  var enableNavigationLinkToProduct = false

  var body: some View {
    Card {
      VStack(alignment: .leading, spacing: 22) {
        Text(title)
          .fontHeavy(size: 16)
          .fgAssetColor(.black)
        
        let items: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
        LazyVGrid(columns: items, spacing: 10) {
          ForEachWithIndex(data: previewProducts) { index, product in
            buildImage(imageUrl: product.image.mediumUrl)
              .onTapGesture {
                tab.goToProduct(id: product.id)
                onSelectItem?("item")
              }
          }
        }
        
        NavigationLink {
          TrendingScreen(products: products)
        } label: {
          Text("See all")
            .fontHeavy(size: 16)
            .fgAssetColor(.purple)
        }
        .frame(maxWidth: .infinity)
      }
    }
  }
  
  @ViewBuilder func buildImage(imageUrl: String) -> some View {
    if enableNavigationLinkToProduct {
      NavigationLink(destination: {
        EmptyView()
      }, label: {
        createImage(url: imageUrl)
      })
    } else {
      createImage(url: imageUrl)
    }
  }
  
  @ViewBuilder func createImage(url: String) -> some View {
    ImageRender(urlPath: url, placeholderRadius: 8) { image in
      image.thumbnail()
    }
    .cornerRadius(8)
  }

}

struct ProductsCard_Previews: PreviewProvider {
  static var previews: some View {
    ProductsCard(title: "Trending Products", products: [])
  }
}

