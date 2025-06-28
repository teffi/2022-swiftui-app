//
//  OnboardingProductScreen.swift
//  Dash
//
//  Created by Steffi Tan on 2/24/22.
//

import SwiftUI

struct OnboardingProductScreen: View {
  @Environment(\.injected) private var dependencies: DIContainer
  @StateObject private var productEnv = ProductEnv()
  @StateObject private var reviewForm = ProductReviewForm()
  @State var stateStore = ProductStateStore()
  @State var product: Loadable<Product> = .idle
  
  let id: String
  var body: some View {
    VStack(alignment: .leading) {
      buildHeader()
      actionView
      Spacer()
    }
    .environment(\.onboardingForm, true)
    .navigationBarHidden(false)
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - View Builders
extension OnboardingProductScreen {
  @ViewBuilder func buildHeader() -> some View {
    switch product {
    case .idle:
      // Render a clear color and start the loading process
      // when the view first appears, which should make the
      // view model transition into its loading state:
      Color.clear
        .onAppear(perform: loadInfo)
    case .loaded(let product):
      ProductHeader(title: product.displayName,
                    imageUrl: product.image.largeUrl,
                    love: String(product.loveCount),
                    hate: String(product.hateCount),
                    user: product.user,
                    willShowSentiment: product.reviewCount > 0)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
        .onAppear {
          productEnv.product = product
        }
    case .failed(_):
      Text("product: failed header data")
    case .isLoading(_, _):
      headerSkeleton
    }
  }
  
  private var actionView: some View {
    ZStack(alignment: .center) {
      VStack(alignment: .center, spacing: 10) {
        Text("Leave a review")
          .fontBold(size: 20)
          .fgAssetColor(.black, opacity: 0.4)
          .multilineTextAlignment(.center)
        Text("How do you feel about this product?")
          .fontRegular(size: 16)
          .fgAssetColor(.black, opacity: 0.4)
          .multilineTextAlignment(.center)
        ProductLoveHateLink(form: reviewForm,
                            size: 61,
                            hasShadow: true,
                            showTitle: true,
                            spacing: 44)
          .padding(.top, 67)
          .environmentObject(productEnv)
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding(.top, 100)
  
  }
  
  private var headerSkeleton: some View {
    HStack {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .frame(width: 94, height: 94)
      Spacer(minLength: 20)
      VStack(alignment: .leading) {
        Rectangle()
          .frame(height: 16)
        Rectangle()
          .frame(height: 16)
      }
    }
    .foregroundColor(Color(.secondarySystemBackground))
    .padding(.bottom, 20)
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity)
  }
}

// MARK: - API functions
extension OnboardingProductScreen {
  func loadInfo() {
    dependencies.interactors.productInteractor.load(id: id, info: $product, store: $stateStore)
  }
}

struct OnboardingProductScreen_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      //OnboardingProductScreen(product: .loaded(Product.seed), id: "123")
      OnboardingProductScreen(id: "123")
        .navigationBarTitleDisplayMode(.inline)
    }
    .navigationViewStyle(.stack)
 
  }
}

//  MARK: - Environment
struct OnboardingFormKey: EnvironmentKey {
  static var defaultValue = false
}
//  MARK: Values
extension EnvironmentValues {
  var onboardingForm: Bool {
    get { self[OnboardingFormKey.self] }
    set { self[OnboardingFormKey.self] = newValue }
  }
}
