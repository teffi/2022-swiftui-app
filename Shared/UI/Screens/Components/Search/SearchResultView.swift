//
//  SearchResultView.swift
//  Dash
//
//  Created by Steffi Tan on 2/8/22.
//

import SwiftUI

/// View that shows a vertically lazy stacked products
struct SearchResultView: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @EnvironmentObject var environment: SearchEnvData
  @Environment(\.searchPresentation) var searchPresentation
  @ObservedObject var store: SearchStore
  @Binding var products: [Search.Product]
  /// Sets to true when add product button is tapped
  @Binding var switchToAddProduct: Bool
  
  let viewId: String

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        buildAddNewProductHeader()
        latestText
        resultRows
//        if store.isLoading {
//          ProgressView()
//            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
//        }
      }// end stack
      .background(
        GeometryReader { Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y) }
      )
      .onPreferenceChange(ViewOffsetKey.self) {
        if $0 != 0 { KeyboardResponder.dismiss() }
      }
    }
    .coordinateSpace(name: "scroll") // end scrollview
  }
}

//  MARK: - Views
extension SearchResultView {
  @ViewBuilder func buildAddNewProductHeader() -> some View {
    Button {
      switchToAddProduct = true
    } label: {
      HStack(alignment: .center) {
        Text("Looking for other products?")
          .fontRegular(size: 11.5)
          .fgAssetColor(.black)
        Spacer()
        Text("Submit using a link")
          .fontRegular(size: 11.5)
          .fgAssetColor(.purple)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }
    .buttonStyle(.plain)
    .bgAssetColor(.gray_1)
    .padding([.vertical], 20)
  }
  
  private var latestText: some View {
    Text("Latest".uppercased())
      .tracking(1.5)
      .fontBold(size: 11.5)
      .fgAssetColor(.black)
      .padding(.horizontal, 20)
      .padding(.bottom, 10)
  }
  
  @ViewBuilder func rowItem(_ item: Search.Product) -> some View {
    //let randomCount = Int.random(in: 1 ..< 100)
    SearchProductRow(name: item.displayName,
                     imageUrl: item.image.mediumUrl,
                     loveCount: item.loveCount,
                     hateCount: item.hateCount)
    
      .id("\(item.id)-\(viewId)")
      .onAppear {
        //store.loadMoreContentIfNeeded(currentItem: item)
      }
  }
  
  @ViewBuilder private var resultRows: some View {
    // Create rows
    ForEach($products) { $product in
      /*
       Build views base on presentation
       - .sheet -> no navigation link, use gesture recognizer on tap and invoke change in environment data which will
       handle dismissing the sheet and navigating to product.
       - .fullScreen -> use navigation link for presenting product screen.
       */
      
      switch searchPresentation {
      case .sheet:
        rowItem(product)
          .padding(.bottom, 12)
          .onTapGesture {
            environment.tab?.goToProduct(id: product.id)
            //print("picking up tap gesture \(product.displayName)")
          }
        
      case .fullScreen:
        // To ProductScreen
        NavigationLink(
          destination: ProductScreen(id: product.id) .inject(dependencies),
          label: {
            rowItem(product).padding(.bottom, 12)
          }
        ).buttonStyle(.plain)
        
      case .onboarding:
        // To Onboarding product
        NavigationLink(
          destination:
            OnboardingProductScreen(id: product.id)
            .inject(dependencies),
          label: {
            rowItem(product)
          }
        )
          .buttonStyle(.plain)
      }
    }// End ForEach
    .padding(.horizontal, 20 )
  }
}

struct SearchResultView_Previews: PreviewProvider {
  static var previews: some View {
    SearchResultView(store: SearchStore(),
                     products: .constant([Search.Product.seed, Search.Product.seed]),
                     switchToAddProduct: .constant(false), viewId: "uniqueid")
      .environmentObject(SearchEnvData())
  }
}

//  MARK: - PreferenceKey
struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}
